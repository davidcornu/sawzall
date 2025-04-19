# frozen_string_literal: true

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
      it "returns nodes that match the CSS selector" do
        doc = Sawzall.parse_document(sample_document)

        selection = doc.select("p")
        expect(selection.size).to eq(1)
        expect(selection[0]).to be_a(Sawzall::Node)
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

      it "returns nothing if there are no matching nodes" do
        doc = Sawzall.parse_document(sample_document)

        selection = doc.select("table")
        expect(selection).to be_empty
      end

      skip "raises an error if the selector is invalid" do
        doc = Sawzall.parse_fragment("")

        expect { doc.select("][") }
          .to raise_error("asdasda")
      end
    end
  end

  describe Sawzall::Node do
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
  end
end
