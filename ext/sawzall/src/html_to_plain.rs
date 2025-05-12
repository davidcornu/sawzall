use ego_tree::iter::Edge;
use lazy_static::lazy_static;
use scraper::{ElementRef, Node};
use std::collections::HashSet;

/// Set of block-level elements extracted from [MDN][1]
///
/// [1]: https://developer.mozilla.org/en-US/docs/Web/HTML/Block-level_elements
const BLOCK_LEVEL_ELEMENTS: [&'static str; 33] = [
    "address",
    "article",
    "aside",
    "blockquote",
    "dd",
    "details",
    "dialog",
    "div",
    "dl",
    "dt",
    "fieldset",
    "figcaption",
    "figure",
    "footer",
    "form",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "header",
    "hgroup",
    "hr",
    "li",
    "main",
    "nav",
    "ol",
    "p",
    "pre",
    "section",
    "table",
    "ul",
];

lazy_static! {
    static ref BLOCK_LEVEL_ELEMENTS_SET: HashSet<&'static str> =
        BLOCK_LEVEL_ELEMENTS.iter().map(|el| *el).collect();
}

fn is_block_element(name: &str) -> bool {
    BLOCK_LEVEL_ELEMENTS_SET.contains(&name)
}

enum Item<'a> {
    Text(&'a str),
    Newlines(usize),
}

/// Converts HTML to plain text using a subset of the [`HTMLElement.innerText`][1]
/// algorithm ([WHATWG spec][2], [Chromium source][3]).
///
/// While the output should be acceptable for documents containing text, no effort
/// was made to support more complex elements (e.g. tables, images, videos, etc...)
/// which have no reasonable use case for the kinds of inputs expected to be handled
/// (e.g. RSS entry titles and summaries)
///
/// [1]: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/innerText
/// [2]: https://html.spec.whatwg.org/multipage/dom.html#the-innertext-idl-attribute
/// [3]: https://source.chromium.org/chromium/chromium/src/+/main:third_party/blink/renderer/core/editing/element_inner_text.cc;l=262;drc=eca6a1b4c221dc66cf40d0d1ee8eff3f3028ce26?q=innerText&ss=chromium
pub(crate) fn html_to_plain(element: ElementRef) -> String {
    let mut item_iter = element
        .traverse()
        .filter_map(|edge| match edge {
            Edge::Open(node) => match node.value() {
                Node::Text(text) if !text.trim().is_empty() => Some(Item::Text(text)),
                Node::Element(element) => match element.name() {
                    "br" => Some(Item::Newlines(1)),
                    "p" => Some(Item::Newlines(2)),
                    name if is_block_element(name) => Some(Item::Newlines(1)),
                    _ => None,
                },
                _ => None,
            },
            Edge::Close(node) => match node.value() {
                Node::Element(element) => match element.name() {
                    "p" => Some(Item::Newlines(2)),
                    name if is_block_element(name) => Some(Item::Newlines(1)),
                    _ => None,
                },
                _ => None,
            },
        })
        .peekable();

    let mut output = String::new();

    while let Some(item) = item_iter.next() {
        match item {
            Item::Text(text) => {
                output.push_str(text);
            }
            Item::Newlines(count) => {
                let mut max = count;

                // Combine all subsequent newlines into one, using the maximum value
                while let Some(Item::Newlines(next_count)) = item_iter.peek() {
                    max = max.max(*next_count);
                    item_iter.next();
                }

                // Don't insert newlines if we're at the beginning or the end
                if !(output.is_empty() || item_iter.peek().is_none()) {
                    output.push_str(&"\n".repeat(max));
                }
            }
        }
    }

    output
}

#[cfg(test)]
mod tests {
    fn html_to_plain(input: &str) -> String {
        let doc = scraper::Html::parse_fragment(input);
        super::html_to_plain(doc.root_element())
    }

    #[test]
    fn test_html_to_plain() {
        assert_eq!("", html_to_plain(""));

        assert_eq!(
            "this is just text",
            html_to_plain("this is just text"),
            "regular text is returned as-is"
        );

        assert_eq!(
            "this is a single paragraph",
            html_to_plain("<p>this is a single paragraph</p>"),
            "single paragraphs do not get leading and trailing newlines"
        );

        assert_eq!(
            "this is a single div",
            html_to_plain("<div>this is a single div</div>"),
            "single block elements do not get leading and trailing newlines"
        );

        assert_eq!(
            "text like <html> is correctly unescaped",
            html_to_plain("<h1>text like &lt;html&gt; is correctly unescaped</h1>"),
            "html-escaped text is correctly unescaped"
        );

        assert_eq!(
            "this bold text is special",
            html_to_plain("<p>this <em>bold</em> text is <span>special</span></p>"),
            "inline elements don't introduce newlines"
        );

        assert_eq!(
            "some deeply nested text",
            html_to_plain("<header><div><h1>some deeply nested text</h1></div></header>"),
            "subsequent block elements do not introduce duplicate newlines"
        );

        assert_eq!(
            "line one\nline two",
            html_to_plain("line one<br>line two"),
            "<br> introduces a single newline"
        );

        assert_eq!(
            "paragraph one\n\nparagraph two",
            html_to_plain("<p>paragraph one</p><p>paragraph two</p>"),
            "paragraphs are separated by two newlines"
        );

        assert_eq!(
            "paragraph one\n\nparagraph two\n\nparagraph three",
            html_to_plain("<p>paragraph one</p><p>paragraph two</p><p>paragraph three</p>"),
            "paragraphs not at the beginning or end are wrapped in two newlines"
        );

        assert_eq!(
            "malformed input\n🙌",
            html_to_plain("<h1>malformed input</br><ul>🙌"),
            "malformed input is handled"
        );

        assert_eq!(
            "Hello, world\n\nThis is an HTML fragment",
            html_to_plain("<h1>Hello, world</h1>\n<p>This is an HTML fragment</p>"),
            "empty lines are ignored"
        );
    }
}
