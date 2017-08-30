$:.push(File.expand_path("../lib", __FILE__))
require 'veritrans/version'

Gem::Specification.new do |s|
  s.name       = "veritrans"
  s.version    = Veritrans::VERSION
  s.author     = ["Veritrans Dev Team"]
  s.description= "Veritrans ruby client"
  s.email      = ["pavel.evstigneev@midtrans.com"]
  s.homepage   = "https://github.com/veritrans/veritrans-ruby"
  s.summary    = %q{Veritrans ruby library}
  s.license    = 'MIT'

  s.files      = `git ls-files`.split("\n")
  s.test_files = []

  s.require_paths = ["lib"] 
  s.executables   = ["veritrans", "midtrans"]

  s.add_runtime_dependency "excon", "~> 0.20"
end

