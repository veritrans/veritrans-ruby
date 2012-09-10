 if ::Object.const_defined?(:Rails) 

  require 'rails/generators'

  module Veritrans
    module Generators
      class InstallGenerator < ::Rails::Generators::Base

        desc <<DESC
Description:
  Copy templates need for veritrans weblinktype payment:
  0. app/controllers/merchant_controller.rb + views
  1. app/controllers/veritrans_controller.rb + views
  2. config/veritrans.yml 
  3. config/routes.rb
DESC
        def create_controller_file
          path = __FILE__.sub(__FILE__.split('/').pop,'templates/app/controllers/')
          create_file("app/controllers/merchant_controller.rb", IO.read("#{path}merchant_controller.rb"))
          create_file("app/controllers/veritrans_controller.rb",IO.read("#{path}veritrans_controller.rb"))
        end

        def create_view_files
          path = __FILE__.sub(__FILE__.split('/').pop,'templates/app/views/layouts/')
          create_file("app/views/layouts/layout_auto_post.html.erb",IO.read("#{path}layout_auto_post.html.erb" ))

          path = __FILE__.sub(__FILE__.split('/').pop,'templates/app/views/merchant/')
          create_file("app/views/merchant/checkout_form.html.erb",IO.read("#{path}checkout_form.html.erb" ))

          path = __FILE__.sub(__FILE__.split('/').pop,'templates/app/views/veritrans/')
          create_file("app/views/veritrans/confirm.html.erb", IO.read("#{path}confirm.html.erb" ))
          create_file("app/views/veritrans/error.html.erb",   IO.read("#{path}error.html.erb"   ))
          create_file("app/views/veritrans/finish.html.erb",  IO.read("#{path}finish.html.erb"  ))
          create_file("app/views/veritrans/postvtw.html.erb", IO.read("#{path}postvtw.html.erb" ))
          create_file("app/views/veritrans/unfinish.html.erb",IO.read("#{path}unfinish.html.erb"))
        end

        def create_or_update_config_files
          path = __FILE__.sub(__FILE__.split('/').pop,'templates/config/')
          create_file("config/veritrans.yml",IO.read("#{path}veritrans.yml"))
        end

        def update_routes
          route("match 'checkout_form'=> 'merchant#checkout_form', :via => :get  # show checkout form")
          route("match 'confirm'      => 'veritrans#confirm',      :via => :post # confirmation autosubmit to veritrans server")
          route("match 'cancel_pay'   => 'veritrans#cancel_pay',   :via => :post # canceling transaction redirect back to merchant-web")
          route("match 'notification' => 'veritrans#notification', :via => :post # server to server notification to merchant-web")
          route("match 'finish'       => 'veritrans#finish',       :via => :post # successfull transaction redirect back to merchant-web")
          route("match 'error'        => 'veritrans#error',        :via => :post # error transaction redirect back to merchant-web")
        end
 
        hook_for :test_framework
      end
    end
  end

end