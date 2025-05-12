# frozen_string_literal: true

# Adapted from https://github.com/gjtorikian/commonmarker/blob/c12e5cbce128fe1863b7290a2403b7b247d79d2e/lib/commonmarker/extension.rb
begin
  # native precompiled gems package shared libraries in <gem_dir>/lib/sawzall/<ruby_version>
  # load the precompiled extension file
  ruby_version = /\d+\.\d+/.match(RUBY_VERSION)
  require_relative "#{ruby_version}/sawzall"
rescue LoadError
  # fall back to the extension compiled upon installation.
  # use "require" instead of "require_relative" because non-native gems will place C extension files
  # in Gem::BasicSpecification#extension_dir after compilation (during normal installation), which
  # is in $LOAD_PATH but not necessarily relative to this file (see nokogiri#2300)
  require "sawzall/sawzall"
end
