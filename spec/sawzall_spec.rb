# frozen_string_literal: true

require "pp"
require "stringio"

RSpec.describe Sawzall do
  it "has a version number" do
    expect(Sawzall::VERSION).not_to be nil
  end

  let(:sample_fragment) do
    <<~HTML
      <h1>Hello, world</h1>
      <p>This is an HTML fragment</p>
    HTML
  end

  let(:sample_document) do
    <<~HTML
      <!doctype html>
      <html>
        <head>
          <title>Test Document</title>
        </head>
        <body>
          <h1>Hello, world</h1>
          <p>This is an HTML document</p>
        </body>
      </html>
    HTML
  end

  describe ".parse_fragment" do
    it "returns a Sawzall::Document" do
      doc = Sawzall.parse_fragment(sample_fragment)

      expect(doc).to be_a(Sawzall::Document)
    end
  end

  describe ".parse_document" do
    it "returns a Sawzall::Document" do
      doc = Sawzall.parse_document(sample_document)

      expect(doc).to be_a(Sawzall::Document)
    end
  end

  describe Sawzall::Document do
    describe "#select" do
      it "returns elements that match the CSS selector" do
        doc = Sawzall.parse_document(sample_document)

        selection = doc.select("p")
        expect(selection.size).to eq(1)
        expect(selection[0]).to be_a(Sawzall::Element)
        expect(selection[0].name).to eq("p")
        expect(selection[0].inner_html).to eq("This is an HTML document")
      end

      it "works with multiple matching elements" do
        doc = Sawzall.parse_fragment(<<~HTML)
          <ul>
            <li>One</li>
            <li>Two</li>
          </ul>
        HTML

        selection = doc.select("ul li")
        expect(selection.map(&:name)).to eq(["li", "li"])
        expect(selection.map(&:inner_html)).to eq(["One", "Two"])
      end

      it "returns nothing if there are no matching elements" do
        doc = Sawzall.parse_document(sample_document)

        selection = doc.select("table")
        expect(selection).to be_empty
      end

      it "raises an error if the selector is invalid" do
        doc = Sawzall.parse_fragment("")

        expect { doc.select("div[]") }
          .to raise_error(ArgumentError, /failed to parse selector "div\[\]"/)
      end
    end

    describe "#root_element" do
      it "returns the root element" do
        doc = Sawzall.parse_fragment("<h1>Heading</h1>")
        element = doc.root_element

        expect(element).to be_a(Sawzall::Element)
        expect(element.name).to eq("html")
        expect(element.html).to eq("<html><h1>Heading</h1></html>")
      end
    end
  end

  describe Sawzall::Element do
    describe "#name" do
      it "returns the element's name" do
        doc = Sawzall.parse_fragment("<h1>Heading</h1>")

        expect(doc.select("h1").first.name).to eq("h1")
      end
    end

    describe "#html" do
      it "returns the element's outer HTML" do
        doc = Sawzall.parse_fragment("<h1>Heading</h1>")

        expect(doc.select("h1").first.html).to eq("<h1>Heading</h1>")
      end
    end

    describe "#inner_html" do
      it "returns the element's inner HTML" do
        doc = Sawzall.parse_fragment("<h1>Heading</h1>")

        expect(doc.select("h1").first.inner_html).to eq("Heading")
      end

      it "returns an empty string if there is no inner HTML" do
        doc = Sawzall.parse_fragment("<img src='https://example.com/image.png'/>")

        expect(doc.select("img").first.inner_html).to eq("")
      end
    end

    describe "#attr" do
      it "returns the attribute value" do
        doc = Sawzall.parse_fragment("<h1 id='main-heading'>Heading</h1>")

        expect(doc.select("h1").first.attr("id")).to eq("main-heading")
      end

      it "returns nil when the attribute does not exist" do
        doc = Sawzall.parse_fragment("<h1 id='main-heading'>Heading</h1>")

        expect(doc.select("h1").first.attr("class")).to be_nil
      end
    end

    describe "#attrs" do
      it "returns an array of key-value pairs" do
        doc = Sawzall.parse_fragment("<h1 id='heading' class='big' data-foo='bar'>Heading</h1>")

        expect(doc.select("h1").first.attrs).to eq([
          ["class", "big"],
          ["data-foo", "bar"],
          ["id", "heading"]
        ])
      end

      it "returns an empty array if there are no attributes" do
        doc = Sawzall.parse_fragment("<h1>Heading</h1>")

        expect(doc.select("h1").first.attrs).to eq([])
      end
    end

    describe "#select" do
      it "returns elements that match the CSS selector" do
        doc = Sawzall.parse_document(sample_document)

        selection = doc.root_element.select("p")
        expect(selection.size).to eq(1)
        expect(selection[0]).to be_a(Sawzall::Element)
        expect(selection[0].name).to eq("p")
        expect(selection[0].inner_html).to eq("This is an HTML document")
      end
    end

    describe "#child_elements" do
      it "returns an array of child elements" do
        doc = Sawzall.parse_fragment(<<~HTML)
          <ul>
            <li id="child1">One</li>
            <li id="child2">
              <ul id="grand-child1">
                <li>Two</li>
                <li>Three</li>
              </ul>
            </li>
          </ul>
        HTML

        ul = doc.select("ul").first
        children = ul.child_elements
        expect(children).to all(be_a(Sawzall::Element))
        expect(children.map { |c| c.attr("id") }).to eq(["child1", "child2"])
        expect(children[1].child_elements.map { |c| c.attr("id") }).to eq(["grand-child1"])
      end

      it "returns an empty array if there are no child elements" do
        doc = Sawzall.parse_fragment("<img src='https://example.com/image.png'/>")

        expect(doc.select("img").first.child_elements).to be_empty
      end
    end

    describe "#text" do
      it "returns the element's text content" do
        doc = Sawzall.parse_fragment(sample_fragment)

        expect(doc.root_element.text).to eq("Hello, world\n\nThis is an HTML fragment")
      end
    end

    describe "#has_class?" do
      it "returns true if the element has the given class" do
        doc = Sawzall.parse_fragment("<h1 class='one two Élément'>Heading</h1>")
        h1 = doc.select("h1").first

        expect(h1).to have_class("one")
        expect(h1).to have_class("OnE", case_sensitive: false)
        expect(h1).not_to have_class("three")

        # Case-insensitive matching is ASCII-only
        expect(h1).to have_class("Élément")
        expect(h1).not_to have_class("élément", case_sensitive: false)
      end
    end

    describe "#classes" do
      it "returns the element's classes" do
        doc = Sawzall.parse_fragment(<<~HTML)
          <h1 class="one two">Heading</h1>
          <h2>Subheading</h1>
        HTML

        expect(doc.select("h1").first.classes).to eq(["one", "two"])
        expect(doc.select("h2").first.classes).to eq([])
      end
    end

    describe "#inspect" do
      it "returns a string containing the name and children" do
        doc = Sawzall.parse_document(sample_document)

        expect(doc.root_element.inspect).to eq(
          "<Sawzall::Element name=\"html\" child_elements=[" \
            "<Sawzall::Element name=\"head\" child_elements=[" \
            "<Sawzall::Element name=\"title\" child_elements=[]>]>, "\
            "<Sawzall::Element name=\"body\" child_elements=[" \
            "<Sawzall::Element name=\"h1\" child_elements=[]>, " \
            "<Sawzall::Element name=\"p\" child_elements=[]>]>]>"
        )
      end
    end

    describe "#pretty_print" do
      it "returns a pretty-printed representation of the element" do
        doc = Sawzall.parse_document(sample_document)
        output = StringIO.new
        PP.pp(doc.root_element, output)

        expect(output.string).to eq(<<~TXT)
          #(Sawzall::Element {
            name = "html",
            child_elements = [
              #(Sawzall::Element {
                name = "head",
                child_elements = [ #(Sawzall::Element { name = "title" })]
                }),
              #(Sawzall::Element {
                name = "body",
                child_elements = [
                  #(Sawzall::Element { name = "h1" }),
                  #(Sawzall::Element { name = "p" })]
                })]
            })
        TXT
      end
    end
  end
end
