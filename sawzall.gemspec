# frozen_string_literal: true

require_relative "lib/sawzall/version"

Gem::Specification.new do |spec|
  spec.name = "sawzall"
  spec.version = Sawzall::VERSION
  spec.authors = ["David Cornu"]
  spec.email = ["me@davidcornu.com"]

  spec.summary = "HTML parsing and querying with CSS selectors."
  spec.description = <<~TXT
    Sawzall wraps the Rust scraper library (https://github.com/rust-scraper/scraper)
    to make it easy to parse HTML documents and query them with CSS selectors.
  TXT
  spec.homepage = "https://github.com/davidcornu/sawzall"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"
  spec.required_rubygems_version = ">= 3.3.11"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://davidcornu.github.io/sawzall/"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  gemspec = File.basename(__FILE__)
  spec.files = [
    gemspec,
    "README.md",
    "LICENSE.txt",
    "Cargo.lock",
    "Cargo.toml"
  ]
  spec.files += Dir.glob([
    "ext/**/*.{rs,toml,lock,rb}",
    "lib/**/*.rb",
  ])

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/sawzall/extconf.rb"]

  spec.add_dependency "rb_sys", "~> 0.9.91"
end
