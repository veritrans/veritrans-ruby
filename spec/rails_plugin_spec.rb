require 'fileutils'
require 'open3'
require 'shellwords'
require 'socket'

describe "Rails plugin", vcr: false do
  include Capybara::DSL

  RAILS_VER = "4.1.9"
  APP_DIR = "plugin_test"
  PLUGIN_DIR = File.expand_path("..", File.dirname(__FILE__))

  before :all do
    FileUtils.mkdir_p("#{PLUGIN_DIR}/tmp")
    #Capybara::Screenshot.instance_variable_set(:@capybara_root, "#{PLUGIN_DIR}/tmp")
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def run_cmd(cmd, cli_args = [])
    full_cmd = ([cmd] + cli_args).join.strip

    stdout_str, stderr_str, status = Open3.capture3(full_cmd)

    if status != 0
      puts "CMD: #{full_cmd}"
      puts "FAILED"
      puts stderr_str

      exit 1
    end

    #puts stdout_str

    return stdout_str
  end

  def install_rails_in_tmp
    @rails_dir = Dir.mktmpdir()
    @app_abs_path = "#{@rails_dir}/#{APP_DIR}"

    Dir.chdir(@rails_dir) do
      Bundler.with_clean_env do
        ENV["RAILS_ENV"] = "development"
        find_or_install_rails
        generate_rails_app
        generate_plugin_things
      end
    end
  end

  def find_or_install_rails
    response = run_cmd('gem list \^rails\$ -q')
    if response =~ /[^\d]#{RAILS_VER}[^\d]/
      return true
    else
      run_cmd("gem install rails -v #{RAILS_VER} --no-ri --no-rdoc")
    end
  end

  def generate_rails_app
    gen = "rails _#{RAILS_VER}_ new #{APP_DIR} -B -G --skip-spring -d sqlite3 --skip-turbolinks --skip-test-unit --no-rc"
    run_cmd(gen)

    gemfile_content = "
      source 'https://rubygems.org'

      gem 'rails', '#{RAILS_VER}'
      gem 'sqlite3'
      gem 'turbolinks'
      gem 'jquery-rails'
      gem 'veritrans', path: '#{PLUGIN_DIR}'
    ".gsub(/^\s+/, '')

    File.open("#{@app_abs_path}/Gemfile", "w") {|f| f.write(gemfile_content) }

    Dir.chdir(@app_abs_path) do
      run_cmd("bundle")
    end
  end

  def generate_plugin_things
    Dir.chdir(@app_abs_path) do
      run_cmd("rails g veritrans:install")
      run_cmd("rails g veritrans:payment_form")
    end

    config_content = "
development:
  client_key: VT-client-NArmatJZqzsmTmzR
  server_key: VT-server-9Htb-RxXkg7-7hznSCCjxvoY
  api_host: https://api.sandbox.veritrans.co.id
"

    File.open("#{@app_abs_path}/config/veritrans.yml", "w") {|f| f.write(config_content) }
  end

  def run_rails_app
    @rails_port = find_open_port

    Bundler.with_clean_env do
      ENV["RAILS_ENV"] = "development"
      Dir.chdir(@app_abs_path) do
        run_cmd("./bin/rails server -d -p #{@rails_port} --bind 127.0.0.1")
      end
    end

    Capybara.app_host = "http://localhost:#{@rails_port}"

    #puts "RAILS_DIR: #{@app_abs_path}"

    while true
      begin
        run_cmd("curl #{Capybara.app_host}/payments/new > /dev/null")
        break
      rescue Object => error
        p error
        puts "Retry"
      end
    end
  end

  def stop_rails_app
    Dir.chdir(@app_abs_path) do
      if File.exist?("./tmp/pids/server.pid")
        run_cmd("kill `cat tmp/pids/server.pid`")
      end
    end
  end

  def find_open_port
    socket = Socket.new(:INET, :STREAM, 0)
    socket.bind(Addrinfo.tcp("127.0.0.1", 0))
    return socket.local_address.ip_port
  ensure
    socket.close
  end

  after do
    stop_rails_app
    FileUtils.remove_entry_secure(@rails_dir) if @rails_dir
  end

  it "should tests plugin" do
    # PREPARE APP
    install_rails_in_tmp
    run_rails_app

    # CREATE PAYMENT 1
    visit "/payments/new"

    click_button "Pay via VT-Direct"

    # Waiting for get token request in javascript...
    Timeout.timeout(30.seconds) do
      loop do
        break if current_path != "/payments/new"
        sleep 0.1
      end
    end

    Timeout.timeout(10.seconds) do
      loop do
        break if page.body =~ /<body>/
        sleep 0.1
      end
    end

    if page.body =~ /too many transactions/
      page.should have_content("Merchant has sent too many transactions to the same card number")
    else
      page.should have_content("Success, Credit Card transaction is successful")
    end

    created_order_id = ActiveSupport::JSON.decode(find("pre").text)["order_id"]
    #Capybara::Screenshot.screenshot_and_open_image

    # CREATE PAYMENT 2
    visit "/payments/new"
    click_link "Pay via VT-Web"

    page.should have_content("Payment is securely processed by Veritrans")
    #Capybara::Screenshot.screenshot_and_open_image

    # TEST CALLBACK FOR WRONG DATA
    stub_const("CONFIG", {})
    result1 = capture_stdout do
      Veritrans::CLI.test_webhook(["#{Capybara.app_host}/payments/receive_webhook"])
    end

    result1.should =~ /status: 404/

    # TEST CALLBACK FOR CORRECT DATA
    stub_const("CONFIG", {order: created_order_id, config_path: "#{@app_abs_path}/config/veritrans.yml"})
    result2 = capture_stdout do
      Veritrans::CLI.test_webhook(["#{Capybara.app_host}/payments/receive_webhook"])
    end

    result2.should =~ /status: 200/
    result2.should =~ /body: ok/
  end

  it "should print message if running in staging" do
    # PREPARE APP
    install_rails_in_tmp
    File.open("#{@app_abs_path}/config/database.yml", 'a') {|f|
      f.puts
      f.puts("staging:")
      f.puts("  adapter: sqlite3")
      f.puts("  database: ':memory:'")
    }

    Bundler.with_clean_env do
      ENV["RAILS_ENV"] = "staging"
      Dir.chdir(@app_abs_path) do
        stdout_str, stderr_str, status = Open3.capture3(%{./bin/rails r 'p :started'})
        stderr_str.should include('Veritrans: Can not find section "staging"')
        stderr_str.should include('Available sections: ["development"]')
        stderr_str.should include('Veritrans: Using first section "development"')
      end
    end
  end
end