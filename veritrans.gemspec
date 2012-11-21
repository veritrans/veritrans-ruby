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

	s.files      = %w[config/veritrans.yml bin/veritrans lib/veritrans lib/veritrans.rb lib/veritrans/client.rb lib/veritrans/v_t_direct.rb lib/veritrans/config.rb lib/veritrans/hash_generator.rb lib/veritrans/post_data.rb lib/veritrans/version.rb lib/generators/install_generator.rb lib/generators/templates/app/controllers/merchant_controller.rb lib/generators/templates/app/controllers/veritrans_controller.rb lib/generators/templates/app/views/layouts/layout_auto_post.html.erb lib/generators/templates/app/views/merchant/checkout.html.erb lib/generators/templates/app/views/veritrans/confirm.html.erb lib/generators/templates/app/views/veritrans/error.html.erb lib/generators/templates/app/views/veritrans/finish.html.erb lib/generators/templates/app/views/veritrans/pay.html.erb lib/generators/templates/app/views/veritrans/cancel.html.erb lib/generators/templates/config/veritrans.yml] 

	s.test_files = []

	s.require_paths = ["lib"] 
    s.executables   = ["veritrans"]
	s.add_runtime_dependency "addressable"
	s.add_runtime_dependency "faraday"
	s.add_runtime_dependency "rake"
end
