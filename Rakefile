# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"
require "rb_sys/extensiontask"

RSpec::Core::RakeTask.new(:spec)

GEMSPEC = Gem::Specification.load("sawzall.gemspec")

RbSys::ExtensionTask.new("sawzall", GEMSPEC) do |ext|
  ext.lib_dir = "lib/sawzall"
end

task build: :compile
task default: %i[compile spec standard]
