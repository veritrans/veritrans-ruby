module Veritrans
  class PaymentFormGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../../templates", __FILE__)

desc %{
Description:
    Copies Veritrans payment form example to your rails application.
}

    def copy_shared_views
      copy_file "views/_veritrans_include.erb", "app/views/shared/_veritrans_include.erb"
      copy_file "views/_credit_card_form.erb", "app/views/shared/_credit_card_form.erb"
    end

    def copy_controller
      copy_file "payments_controller.rb", "app/controllers/payments_controller.rb"

      route "resources :payments do\n" +
          "    collection do\n" +
          "      post :receive_webhook\n" +
          "    end\n" +
          "  end"

      copy_file "views/payments/new.erb", "app/views/payments/new.erb"
      copy_file "views/payments/create.erb", "app/views/payments/create.erb"
    end

    def append_javascript_file
      copy_file "assets/credit_card_form.js", "app/assets/javascripts/credit_card_form.js"
      insert_into_file "app/assets/javascripts/application.js", :after => %r{//= require +['"]?jquery['"]?$} do
        "\n//= require credit_card_form"
      end

say_status "", %{

Sample form installed in you app!
It contains example for VT-Web and VT-Direct

Now open http://localhost:3000/payments/new

}

    end
  end
end
