class Veritrans
  class InstallGenerator < ::Rails::Generators::Base # :nodoc:
    source_root File.expand_path("../../templates", __FILE__)

desc %{
Description:
    Copies Veritrans configuration file to your application's initializer directory.
}

    desc "copy veritrans.yml"
    def copy_config_file
      copy_file "veritrans.yml", "config/veritrans.yml"
    end

    desc "copy initializer veritrans.rb"
    def copy_initializer_file
      copy_file "./veritrans.rb", "config/initializers/veritrans.rb"

say_status "", %{

We copy configs in your rails application
Please edit:

  config/veritrans.yml

}


    end

  end
end
