require 'yaml'

module Veritrans

  module Config
    extend self

    @api_host = "https://api.sandbox.veritrans.co.id"

    def client_key
      @client_key
    end

    def client_key=(value)
      @client_key = value
    end

    def server_key
      @server_key
    end

    def server_key=(value)
      @server_key = value
    end

    def api_host
      @api_host
    end

    def api_host=(value)
      @api_host = value
    end

    def load_yml(filename)
      yml_file, yml_section = filename.split('#')
      config_data = YAML.load(File.read(yml_file))

      apply(yml_section ? config_data[yml_section] : config_data)
    end

    private

    def apply(hash)
      hash.each do |key, value|
        send(:"#{key}=", value)
      end
    end
  end

end