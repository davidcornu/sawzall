# frozen_string_literal: true

require_relative "sawzall/version"
require_relative "sawzall/sawzall"

module Sawzall
  # Parses the given string as an HTML fragment
  #
  # @!method self.parse_fragment(html)
  # @param html [String]
  # @return [Sawzall::Document]
  #
  # @example
  #   Sawzall
  #     .parse_fragment("<h1 id='title'>Page Title</h1>")
  #     .select("h1")
  #     .first
  #     .attr("id") #=> "title"

  # Parses the given string as a complete HTML document
  #
  # @!method self.parse_document(html)
  # @param html [String]
  # @return [Sawzall::Document]
  #
  # @example
  #   html = <<~HTML
  #     <!doctype html>
  #     <html>
  #       <head>
  #         <title>Page Title</title>
  #       </head>
  #       <body>
  #         <h1>Heading</h1>
  #       </body>
  #     </html>
  #   HTML
  #
  #   Sawzall
  #     .parse_document(html)
  #     .select("head title")
  #     .first
  #     .text #=> "Page Title"

  # @!parse
  #   class Document
  #     # Returns the elements that match the given [CSS selector][mdn]
  #     #
  #     # [mdn]: https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_selectors
  #     #
  #     # @example
  #     #   doc = Sawzall.parse_fragment(<<~HTML)
  #     #     <h1>Heading</h1>
  #     #     <p>Paragraph 1</p>
  #     #     <p>Paragraph 2</p>
  #     #   HTML
  #     #   matches = doc.select("p")
  #     #   matches.map(&:text) #=> ["Paragraph 1", "Paragraph 2"]
  #     #
  #     # @!method select(css_selector)
  #     # @param css_selector [String]
  #     # @raise [ArgumentError] if the CSS selector is invalid
  #     # @return [Array<Sawzall::Element>]
  #
  #     # Returns the document's root element
  #     #
  #     # @example
  #     #   doc = Sawzall.parse_fragment("<h1>Heading</h1>")
  #     #   doc.root_element.name #=> "html"
  #     #   doc.root_element.child_elements.map(&:name) #=> ["h1"]
  #     #
  #     # @!method root_element
  #     # @return [Sawzall::Element]
  #   end

  # @!parse
  #   class Element
  #     # Returns the element's name in lowercase
  #     #
  #     # @example
  #     #   doc = Sawzall.parse_fragment("<p>Paragraph</p>")
  #     #   doc.select("p").first.name #=> "p"
  #     #
  #     # @!method name
  #     # @return [String]
  #
  #     # Returns the element's outer HTML
  #     #
  #     # @example
  #     #   doc = Sawzall.parse_fragment(<<~HTML)
  #     #     <section>
  #     #       <h1>Heading</h1>
  #     #     </section>
  #     #   HTML
  #     #   section = doc.select("section").first
  #     #   section.html #=> "<section>\n<h1>Heading</h1>\n</section>"
  #     #
  #     # @!method html
  #     # @return [String]
  #
  #     # Returns the element's inner HTML
  #     #
  #     # @example
  #     #   doc = Sawzall.parse_fragment(<<~HTML)
  #     #     <section>
  #     #       <h1>Heading</h1>
  #     #     </section>
  #     #   HTML
  #     #   section = doc.select("section").first
  #     #   section.inner_html #=> "\n<h1>Heading</h1>\n"
  #     #
  #     # @!method inner_html
  #     # @return [String]
  #
  #     # Returns the given attribute's value or `nil`
  #     #
  #     # @example
  #     #   doc = Sawzall.parse_fragment("<h1 id='title'>Heading</h1>")
  #     #   h1 = doc.select("h1").first
  #     #   h1.attr("id") #=> "title"
  #     #   h1.attr("class") #=> nil
  #     #
  #     # @!method attr(attribute)
  #     # @param attribute [String]
  #     # @return [String, Nil]
  #
  #     # Returns the child elements that match the given CSS selector
  #     #
  #     # https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_selectors
  #     #
  #     # @example
  #     #   doc = Sawzall.parse_fragment(<<~HTML)
  #     #     <div class="container">
  #     #       <div>inner div 1</div>
  #     #       <div>inner div 2</div>
  #     #     </div>
  #     #   HTML
  #     #   container = doc.select(".container").first
  #     #   matches = container.select("div")
  #     #   matches.map(&:text) #=> ["inner div 1", "inner div 2"]
  #     #
  #     # @!method select(css_selector)
  #     # @param css_selector [String]
  #     # @raise [ArgumentError] if the CSS selector is invalid
  #     # @return [Array<Sawzall::Element>]
  #
  #     # Returns the element's child elements
  #     #
  #     # @example
  #     #   doc = Sawzall.parse_fragment(<<~HTML)
  #     #     <div id="parent">
  #     #       <div id="child1">
  #     #         <div id="grandchild1"></div>
  #     #       </div>
  #     #       <div id="child2"></div>
  #     #     </div>
  #     #   HTML
  #     #   parent = doc.select("#parent").first
  #     #   parent
  #     #     .child_elements
  #     #     .map { it.attr("id") } #=> ["child1", "child2"]
  #     #
  #     # @!method child_elements
  #     # @return [Array<Sawzall::Element>]
  #
  #     # Returns the element's text content using a very simplified version of the
  #     # `innerText` algorithm.
  #     #
  #     # https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/innerText
  #     #
  #     # @example
  #     #   doc = Sawzall.parse_fragment(<<~HTML)
  #     #     <ul>
  #     #       <li>First item</li>
  #     #       <li>Second item</li>
  #     #     </ul>
  #     #   HTML
  #     #   ul = doc.select("ul").first
  #     #   ul.text #=> "First item\nSecond item"
  #     #
  #     # @!method text
  #     # @return [String]
  #   end
end
