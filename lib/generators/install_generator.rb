 if ::Object.const_defined?(:Rails) 

  require 'rails/generators'

  module Veritrans
    module Generators
      class InstallGenerator < ::Rails::Generators::Base

        desc <<DESC
Description:
  Copy veritrans.yml template need for veritrans weblinktype payment:
  - config/veritrans.yml 
DESC

        def create_or_update_config_files
          path = __FILE__.sub(__FILE__.split('/').pop,'templates/config/')
          create_file("config/veritrans.yml",IO.read("#{path}veritrans.yml"))
        end

      end

      class SampleGenerator < ::Rails::Generators::Base

        desc <<DESC
Description:
  Copy templates need for veritrans weblinktype payment:
  - app/controllers/merchant_controller.rb + views
  - app/controllers/veritrans_controller.rb + views
  - config/veritrans.yml 
  - config/routes.rb
DESC
        def create_controller_file
          acts = "app/controllers/vtlink/"
          path = __FILE__.sub(__FILE__.split('/').pop,"templates/#{acts}")
          create_file("#{acts}merchant_controller.rb", IO.read("#{path}merchant_controller.rb"))
          create_file("#{acts}veritrans_controller.rb",IO.read("#{path}veritrans_controller.rb"))
        end

        def create_view_files
          acts = "app/views/layouts/"
          path = __FILE__.sub(__FILE__.split('/').pop,"templates/#{acts}")
          create_file("#{acts}layout_auto_post.html.erb",IO.read("#{path}layout_auto_post.html.erb" ))

          acts = "app/views/vtlink/merchant/"
          path = __FILE__.sub(__FILE__.split('/').pop,"templates/#{acts}")
          create_file("#{acts}checkout.html.erb",IO.read("#{path}checkout.html.erb" ))

          acts = "app/views/vtlink/veritrans/"
          path = __FILE__.sub(__FILE__.split('/').pop,"templates/#{acts}")
          create_file("#{acts}confirm.html.erb", IO.read("#{path}confirm.html.erb"))
          create_file("#{acts}cancel.html.erb",  IO.read("#{path}cancel.html.erb" ))
          create_file("#{acts}pay.html.erb",     IO.read("#{path}pay.html.erb"    ))
          create_file("#{acts}finish.html.erb",  IO.read("#{path}finish.html.erb" ))
          create_file("#{acts}error.html.erb",   IO.read("#{path}error.html.erb"  ))
        end

        def create_or_update_config_files
          path = __FILE__.sub(__FILE__.split('/').pop,'templates/config/')
          create_file("config/veritrans.yml",IO.read("#{path}veritrans.yml"))
        end

        def update_routes
          route("end")
          route("  match '/' => 'merchant#checkout', :via => :get  # show checkout form")
          route("  match 'confirm'  => 'veritrans#confirm', :via => :post # pay-confirmation autosubmit to veritrans server")
          route("  match 'cancel'   => 'veritrans#cancel',  :via => :post # canceling transaction redirect back to merchant-web")
          route("  match 'pay'      => 'veritrans#pay',     :via => :post # server to server pay-notification to merchant-web")
          route("  match 'finish'   => 'veritrans#finish',  :via => :post # successfull transaction redirect back to merchant-web")
          route("  match 'error'    => 'veritrans#error',   :via => :post # error transaction redirect back to merchant-web")
          route("namespace :vtlink do")
        end
 
        hook_for :test_framework
      end
    end
  end

end