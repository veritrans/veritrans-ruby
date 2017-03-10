require 'json'
require 'securerandom'
require 'logger'

class Veritrans
  module CLI #:nodoc:
    # can't find order
    class OrderNotFound < Exception; end  # :nodoc:
    class AuthenticationError < Exception; end  # :nodoc:

    extend self

    def test_webhook(args)
      url = args.shift
      raise ArgumentError, "missing required parameter URL" unless url && url != ""

      options = {
        body: json_data,
        headers: {
          :Accept => "application/json",
          :"Content-Type" => "application/json",
          :"User-Agent" => "Veritrans gem #{Veritrans::VERSION} - webhook tester"
        },
        read_timeout: 10,
        write_timeout: 10,
        connect_timeout: 10
      }

      puts "Sending #{options[:body].length} bytes to:"
      puts " => #{cyan(url)}"
      # Print body if it's custom
      puts options[:body] + "\n\n" if CONFIG[:order]

      s_time = Time.now
      response = Excon.post(url, options)
      response.body = response.body.to_s.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})

      puts "Got response: (#{((Time.now - s_time) * 1000).round}ms)"
      puts "  status: #{response.status}"
      puts "  body: #{response.body}"

      if response.status >= 200 && response.status < 300
        puts green("Success!")
      else
        puts red("Failed!")
        puts "Response status is #{response.status} not 200"
      end
    #rescue Object => error
    #  puts red("Failed!")
    #  puts error.message
    end

    def load_local_config!
      if CONFIG[:config_path]
        if File.exists?(CONFIG[:config_path])
          config_file = CONFIG[:config_path]
        else
          raise ArgumentError, "Can not find config at #{CONFIG[:config_path]}" unless config_file
        end
      end


      if File.exists?("./veritrans.yml")
        config_file = "./veritrans.yml"
      end
      if File.exists?("./config/veritrans.yml")
        config_file = "./config/veritrans.yml"
      end

      raise ArgumentError, "Can not find config at ./config/veritrans.yml or ./veritrans.yml" unless config_file

      puts "#{green('*')} Load config #{config_file}"
      ENV['RAILS_ENV'] ||= 'development'
      Veritrans.setup.load_yml("#{config_file}##{ENV['RAILS_ENV']}")

      if !Veritrans.config.client_key || Veritrans.config.client_key == ""
        puts red("Error")
        raise ArgumentError, "Can not find client_key in #{config_file}"
      end

      if !Veritrans.config.server_key || Veritrans.config.server_key == ""
        puts red("Error")
        raise ArgumentError, "Can not find server_key in #{config_file}"
      end

    end

    def get_order_info(order_id)
      puts "#{green('*')} Getting order #{order_id}"
      Veritrans.logger = Logger.new("/dev/null")
      response = Veritrans.status(order_id)
      if response.success?
        return response
      else
        puts red("Error")

        if response.status_code == 401
          raise AuthenticationError, "Can not find order with id=#{order_id} (#{response.status_message})"
        else
          raise OrderNotFound, "Can not find order with id=#{order_id} (#{response.status_message})"
        end
      end
    end

    def json_data
      data = {
        status_code: "200",
        status_message: "Veritrans payment notification",
        transaction_id: SecureRandom.uuid,
        order_id: "cli-testin-#{rand}",
        payment_type: "credit_card",
        transaction_time: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        transaction_status: "capture",
        fraud_status: "accept",
        masked_card: "411111-1111",
        gross_amount: "50000.0"
      }

      if CONFIG[:order]
        load_local_config!
        order_info = get_order_info(CONFIG[:order])
        order_data = hash_except(order_info.data, :status_message, :signature_key)
        data = hash_except(data, :fraud_status, :masked_card).merge(order_data)
      end

      JSON.pretty_generate(data)
    end

    def colorize(str, color_code)
      "\e[#{color_code}m#{str}\e[0m"
    end

    def red(str)
      colorize(str, 31)
    end

    def green(str)
      colorize(str, 32)
    end

    def yellow(str)
      colorize(str, 33)
    end

    def blue(str)
      colorize(str, 34)
    end

    def pink(str)
      colorize(str, 35)
    end
    def cyan(str); colorize(str, 36) end

    def hash_except(hash, *except_keys)
      copy = hash.dup
      except_keys.each { |key| copy.delete(key) }
      copy
    end

  end
end