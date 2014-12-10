$:.push(File.expand_path("../lib", __FILE__))
require 'veritrans/version'

Gem::Specification.new do |s|
  s.name       = "veritrans"
  s.version    = Veritrans::VERSION
  s.author     = ["Veritrans Dev Team"]
  s.email      = ["dev@veritrans.co.id"]
  s.homepage   = "https://github.com/veritrans/veritrans-ruby"
  s.summary    = %q{Veritrans ruby library}

  s.files      = `git ls-files`.split("\n")
  s.test_files = []

  s.require_paths = ["lib"] 
  s.executables   = ["veritrans"]

  s.add_runtime_dependency "excon", "~> 0.20"

  s.add_development_dependency "rspec", ">= 2.9.0"
  s.add_development_dependency "rails"
  s.add_development_dependency 'webmock'
end
