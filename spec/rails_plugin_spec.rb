require 'fileutils'
require 'open3'
require 'shellwords'
require 'socket'

describe 'Rails plugin', vcr: false do
  include Capybara::DSL

  MAIN_RAILS_VER = '5.1.0'.freeze
  APP_DIR = 'plugin_test'.freeze
  PLUGIN_DIR = File.expand_path('..', File.dirname(__FILE__))

  RAILS_VERSIONS = %w[4.1.16 4.2.10 5.0.6 5.1.5].freeze

  before :all do
    FileUtils.mkdir_p("#{PLUGIN_DIR}/tmp")
    # Capybara::Screenshot.instance_variable_set(:@capybara_root, "#{PLUGIN_DIR}/tmp")
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

    puts "RUN: #{full_cmd}" if ENV['DEBUG']

    output, status = Open3.capture2e(full_cmd)

    if status != 0
      puts "CMD: #{full_cmd}"
      puts 'FAILED'
      puts output

      exit 1
    end
    output
  end

  def install_rails_in_tmp(rails_version = MAIN_RAILS_VER)
    @rails_dir = Dir.mktmpdir
    @app_abs_path = "#{@rails_dir}/#{APP_DIR}"

    Dir.chdir(@rails_dir) do
      Bundler.with_clean_env do
        ENV['RAILS_ENV'] = 'development'
        find_or_install_rails(rails_version)
        generate_rails_app(rails_version)
        generate_plugin_things
      end
    end
  end

  def find_or_install_rails(rails_version)
    response = run_cmd('gem list \^rails\$ -q')

    return true if response =~ /[^\d]#{rails_version}[^\d]/

    run_cmd("gem install rails -v #{rails_version}")
  end

  def generate_rails_app(rails_version)
    gemfile_content = "
      source 'https://rubygems.org'

      gem 'rails', '#{rails_version}'
      gem 'sqlite3', '~> 1.3.13'
      gem 'turbolinks'
      gem 'jquery-rails'
      gem 'veritrans', path: '#{PLUGIN_DIR}'
    ".gsub(/^\s+/, '')

    File.open('./Gemfile', 'w') { |f| f.write(gemfile_content) }
    run_cmd('bundle')

    gen = "bundle exec rails _#{rails_version}_ new #{APP_DIR} -B -G --skip-spring -d sqlite3 --skip-turbolinks --skip-test-unit --skip-action-cable --no-rc --skip-puma --skip-listen"

    run_cmd(gen)

    File.open("#{@app_abs_path}/Gemfile", 'w') { |f| f.write(gemfile_content) }

    Dir.chdir(@app_abs_path) do
      run_cmd('bundle')
    end
  end

  def generate_plugin_things
    Dir.chdir(@app_abs_path) do
      run_cmd('rails g veritrans:install')
      run_cmd('rails g veritrans:payment_form')
    end

    config_content = "
development:
  client_key: VT-client-NArmatJZqzsmTmzR
  server_key: VT-server-9Htb-RxXkg7-7hznSCCjxvoY
  api_host: https://api.sandbox.midtrans.com
"

    File.open("#{@app_abs_path}/config/veritrans.yml", 'w') { |f| f.write(config_content) }
  end

  def run_rails_app
    @rails_port = find_open_port

    server_cmd = "./bin/rails server -p #{@rails_port} -b 127.0.0.1"
    server_env = { "RAILS_ENV" => 'development', "BUNDLE_GEMFILE" => @app_abs_path + '/Gemfile' }
    spawn_opts = { chdir: @app_abs_path }
    spawn_opts[%i[err out]] = '/dev/null' unless ENV['DEBUG']

    Bundler.with_clean_env do
      puts "RUN: #{server_cmd} #{spawn_opts}" if ENV['DEBUG']
      @runner_pid = spawn(server_env, server_cmd, spawn_opts)
      puts "Process running PID: #{@runner_pid}" if ENV['DEBUG']
    end

    Capybara.app_host = "http://127.0.0.1:#{@rails_port}"

    # puts "RAILS_DIR: #{@app_abs_path}"

    check_cmd = "curl #{Capybara.app_host}/payments/new"

    failed = 0
    while failed < 100
      puts "Check if rails server UP (#{Capybara.app_host})" if ENV['DEBUG']
      output, status = Open3.capture2e(check_cmd)
      if status == 0 && output =~ /credit_card_number/
        if ENV['DEBUG']
          puts 'Server is running, output:'
          puts output[0..300]
        end
        break
      else
        failed += 1
        sleep 0.3
      end
    end

    return if failed != 100

    puts `tail -100 #{@app_abs_path}/log/development.log`
    raise Exception, 'cannot start rails server'
  end

  def stop_rails_app
    Dir.chdir(@app_abs_path) do
      run_cmd('kill `cat tmp/pids/server.pid`') if File.exist?('./tmp/pids/server.pid')
    end
  end

  def find_open_port
    socket = Socket.new(:INET, :STREAM, 0)
    socket.bind(Addrinfo.tcp('127.0.0.1', 0))
    socket.local_address.ip_port
  ensure
    socket.close
  end

  after do
    stop_rails_app
    FileUtils.remove_entry_secure(@rails_dir) if @rails_dir
  end

  def submit_payment_form(card_number)
    # CREATE PAYMENT 1
    visit '/payments/new'

    fill_in 'credit_card_number', with: card_number
    click_button 'Pay via VT-Direct'
    puts 'Clicked Pay'

    # Waiting for get token request in javascript...
    Timeout.timeout(60.seconds) do
      loop do
        break if current_path != '/payments/new'

        sleep 1
      end
    end

    Timeout.timeout(10.seconds) do
      loop do
        break if page.body =~ /<body>/

        sleep 0.1
      end
    end
  end

  RAILS_VERSIONS.each_with_index do |rails_version, spec_index|
    next if rails_version.start_with?('5') && RUBY_VERSION < '2.2.2'
    next if RUBY_VERSION >= '2.4.0' && rails_version < '4.2.0'

    it "should tests plugin (Rails #{rails_version})" do
      puts "Testing with Rails #{rails_version} and Ruby #{RUBY_VERSION}"
      # PREPARE APP
      install_rails_in_tmp(rails_version)
      run_rails_app

      card_numbers = [
        '5481 1611 1111 1081',
        '5410 1111 1111 1116',
        '4011 1111 1111 1112',
        '4411 1111 1111 1118',
        '4811 1111 1111 1114',
        '3528 6647 7942 9687',
        '3528 2033 2456 4357'
      ]
      spec_index = (spec_index + RUBY_VERSION.gsub(/[^\d]/, '').to_i) % card_numbers.size
      card_number = card_numbers[spec_index]

      submit_payment_form(card_number)

      if page.body =~ /too many transactions/
        puts '!!!!'
        puts 'Merchant has sent too many transactions to the same card number'
        puts '!!!!'
        # page.should have_content("Merchant has sent too many transactions to the same card number")
        puts 'Wait 10 seconds and retry'
        sleep 10
        submit_payment_form(card_number)
      end

      puts page.body if page.body !~ /transaction is successful/

      page.should have_content('Success, Credit Card transaction is successful')

      order_info = ActiveSupport::JSON.decode(find('pre').text)
      puts "Order Info: #{order_info}"
      created_order_id = order_info['order_id']
      # Capybara::Screenshot.screenshot_and_open_image

      # CREATE PAYMENT 2
      visit '/payments/new'
      click_link 'Pay via VT-Web'

      page.should have_content('ATM/Bank Transfer')

      # TEST CALLBACK FOR WRONG DATA
      stub_const("CONFIG", {})
      result1 = capture_stdout do
        Veritrans::CLI.test_webhook(["#{Capybara.app_host}/payments/receive_webhook"])
      end

      result1.should =~ /status: 404/

      # TEST CALLBACK FOR CORRECT DATA
      stub_const('CONFIG', order: created_order_id, config_path: "#{@app_abs_path}/config/veritrans.yml")
      result2 = capture_stdout do
        Veritrans::CLI.test_webhook(["#{Capybara.app_host}/payments/receive_webhook"])
      end

      puts `tail -40 #{@app_abs_path}/log/development.log` if result2 !~ /status: 200/

      result2.should =~ /status: 200/
      result2.should =~ /body: ok/
    end
  end

  it 'should print message if running in staging' do
    # PREPARE APP
    install_rails_in_tmp
    File.open("#{@app_abs_path}/config/database.yml", 'a') { |f|
      f.puts
      f.puts('staging:')
      f.puts('  adapter: sqlite3')
      f.puts("  database: ':memory:'")
    }

    Bundler.with_clean_env do
      ENV['RAILS_ENV'] = 'staging'
      Dir.chdir(@app_abs_path) do
        stdout_str, stderr_str, status = Open3.capture3(%(./bin/rails r 'p :started'))
        stderr_str.should include('Veritrans: Can not find section "staging"')
        stderr_str.should include('Available sections: ["development"]')
        stderr_str.should include('Veritrans: Using first section "development"')
      end
    end
  end

  it 'should create logs for log/veritrans.log' do
    install_rails_in_tmp
    FileUtils.rm_rf(@app_abs_path + '/log')
    File.open(@app_abs_path + '/config/application.rb', 'a') do |f|
      f.write %{
        logger = ActiveSupport::Logger.new(STDOUT)
        Rails.application.config.logger = ActiveSupport::TaggedLogging.new(logger)
      }
    end
    run_rails_app

    response = Excon.post(
      "#{Capybara.app_host}/payments/receive_webhook",
      body: { transaction_id: '111' }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
    expect(response.body).to eq 'error'
    expect(response.status).to eq 404

    expect(File.exist?(@app_abs_path + '/log/development.log')).to eq false
    expect(File.exist?(@app_abs_path + '/log/veritrans.log')).to eq true

    File.read(@app_abs_path + '/log/veritrans.log').should include('Callback verification failed for order')
  end
end