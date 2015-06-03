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
  spec.description   = File.read('README.md').split("\n").reject{|l| l.length == 0 || l =~ /^[#=]+/ }.first
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/worshare/#{spec.name.gsub('_','-')}"
  spec.license       = "Copyright"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "forwarding_dsl"
end
