# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cbf/version'

Gem::Specification.new do |s|
  s.name          = "cbf"
  s.version       = CBF::VERSION
  s.authors       = ["Tomas Sedovic"]
  s.email         = ["tomas@sedovic.cz"]
  s.summary       = "Convert between various cloud deployment formats."
  s.description   = "Cloud Babel Fish is a tool an a library for converting between the different multi-instance cloud deployment templates."
  s.homepage      = "https://github.com/tomassedovic/cbf"
  s.license       = 'Apache License, Version 2.0'

  s.add_runtime_dependency "nokogiri", "~> 1.5.0"

  s.add_development_dependency "rake", "~> 10.0.2"

  s.files         = `git ls-files`.split($/)
  s.bindir        = 'bin'
  s.executables   = 'cbf'
  s.test_files    = s.files.grep(%r{spec/})
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 1.9.2'
end
