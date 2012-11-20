$:.unshift File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name          = "cbf"

  s.version       = '0.0.1'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Tomas Sedovic"]
  s.email         = ["tomas@sedovic.cz"]
  s.homepage      = "http://example.com/cbf"
  s.summary       = "Convert between various cloud deployment formats."
  s.description   = "Cloud Babel Fish is a tool an a library for converting between the different multi-instance cloud deployment templates."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "cbf"

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files`.split("\n").map{|f| f[/^bin\/(.*)/, 1]}.compact
  s.require_path  = 'lib'
end

