# Sawzall 🪚

Sawzall wraps the Rust scraper library (https://github.com/rust-scraper/scraper) to make it easy to parse HTML documents and query them with CSS selectors.

```ruby
require "sawzall"
require "net/http"

doc = Sawzall.parse_document(Net::HTTP.get("example.org", "/"))
doc.select("title").first.text #=> "Example Domain"
```

> [!NOTE]
> Sawzall is a hobby project. Expect ongoing development and maintenance to be very much correlated to how much value it brings me as a learning resource and as a tool for my other projects.
>
> You are welcome to report bugs you run into or submit pull requests for changes that would make it more useful for your use-case, but please bear the above in mind.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add sawzall
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install sawzall
```

## Usage

[API documentation](https://davidcornu.github.io/sawzall/)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidcornu/sawzall.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
