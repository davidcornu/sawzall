use ego_tree::NodeId;
use magnus::{function, method, prelude::*, Error, RArray, Ruby};
use scraper::{ElementRef, Html, Selector};
use std::sync::{Arc, Mutex};

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("Sawzall")?;
    module.define_singleton_method("parse_fragment", function!(parse_fragment, 1))?;
    module.define_singleton_method("parse_document", function!(parse_document, 1))?;

    let document_class = module.define_class("Document", ruby.class_object())?;
    document_class.define_method("select", method!(Document::select, 1))?;
    document_class.define_method("root_element", method!(Document::root_element, 0))?;

    let node_class = module.define_class("Node", ruby.class_object())?;
    node_class.define_method("name", method!(Node::name, 0))?;
    node_class.define_method("html", method!(Node::html, 0))?;
    node_class.define_method("inner_html", method!(Node::inner_html, 0))?;
    node_class.define_method("attr", method!(Node::attr, 1))?;

    Ok(())
}

fn parse_fragment(fragment: String) -> Document {
    Document::new(Html::parse_fragment(&fragment))
}

fn parse_document(document: String) -> Document {
    Document::new(Html::parse_document(&document))
}

#[derive(Clone)]
#[magnus::wrap(class = "Sawzall::Document", free_immediately)]
struct Document(Arc<Mutex<Html>>);

impl Document {
    fn new(html: Html) -> Self {
        Self(Arc::new(Mutex::new(html)))
    }

    fn with_locked_html<U, F>(&self, f: F) -> U
    where
        F: FnOnce(&Html) -> U,
    {
        let html = self.0.lock().expect("failed to lock mutex");

        f(&html)
    }

    fn select(&self, css_selector: String) -> Result<RArray, Error> {
        self.with_locked_html(|html| select(css_selector, self.clone(), html.root_element()))
    }

    fn root_element(&self) -> Node {
        self.with_locked_html(|html| Node {
            id: html.root_element().id(),
            document: self.clone(),
        })
    }
}

fn select(
    css_selector: String,
    document: Document,
    element_ref: ElementRef,
) -> Result<RArray, Error> {
    let ruby = Ruby::get().expect("called from non-ruby thread");

    let selector = Selector::parse(&css_selector).map_err(|e| {
        Error::new(
            ruby.exception_arg_error(),
            format!("failed to parse selector {css_selector:?}\n{e}"),
        )
    })?;

    let rarray = RArray::new();

    for element_ref in element_ref.select(&selector) {
        let node = Node {
            id: element_ref.id(),
            document: document.clone(),
        };
        rarray.push(node)?;
    }

    Ok(rarray)
}

#[magnus::wrap(class = "Sawzall::Node", free_immediately)]
struct Node {
    id: NodeId,
    document: Document,
}

impl Node {
    fn with_element_ref<U, F>(&self, f: F) -> U
    where
        F: FnOnce(ElementRef) -> U,
    {
        let html = self.document.0.lock().expect("failed to lock mutex");
        let element_ref = html
            .tree
            .get(self.id)
            .and_then(ElementRef::wrap)
            .expect("node with id {self.id} must be an element in the tree");

        f(element_ref)
    }

    fn name(&self) -> String {
        self.with_element_ref(|element_ref| element_ref.value().name().to_string())
    }

    fn html(&self) -> String {
        self.with_element_ref(|element_ref| element_ref.html())
    }

    fn inner_html(&self) -> String {
        self.with_element_ref(|element_ref| element_ref.inner_html())
    }

    fn attr(&self, attribute: String) -> Option<String> {
        self.with_element_ref(|element_ref| element_ref.attr(&attribute).map(ToString::to_string))
    }
    // text
    // children
}
