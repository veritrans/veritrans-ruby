$:.push File.expand_path("../lib",__FILE__)
require 'veritrans/version'

Gem::Specification.new do |s|
	s.name       = "veritrans"
	s.version    = Veritrans::Version
	s.author     = ["Veritrans Dev Team"]
	s.email      = ["dev@veritrans.co.id"]
	s.homepage   = "http://veritrans.co.id"
	s.summary    = %q{Veritrans Webclient wrapper}

	s.rubyforge_project = "veritrans"

	s.files      = %w[config/veritrans.yml bin/veritrans lib/veritrans lib/veritrans.rb lib/veritrans/client.rb lib/veritrans/config.rb lib/veritrans/hash_generator.rb lib/veritrans/post_data.rb lib/veritrans/version.rb]

	s.test_files = []

	s.require_paths = ["lib"] 
    s.executables   = ["veritrans"]
	s.add_runtime_dependency "addressable"
	s.add_runtime_dependency "faraday"
	s.add_runtime_dependency "rake"
end
