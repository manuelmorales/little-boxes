# coding: utf-8
gem_name = "little_boxes" # TODO: Rename this

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "#{gem_name}/version"

Gem::Specification.new do |spec|
  spec.name          = gem_name
  spec.version       = LittleBoxes::VERSION
  spec.authors       = ["Workshare's dev team"]
  spec.email         = ['_Development@workshare.com']
  spec.summary       = "Dependency injection library in Ruby."
  spec.description   = "LittleBoxes is a light library that provides a dependency tree that represents your application configuration. It automatically configures your dependencies and lazy-loads by default."
  spec.homepage      = "https://github.com/worshare/#{spec.name.gsub('_','-')}"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", "~> 12.0"
end
