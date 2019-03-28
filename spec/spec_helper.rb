require 'bundler/setup'

$LOAD_PATH.push(File.expand_path('../lib', __dir__))

require 'rspec'
require 'veritrans'
require 'veritrans/cli'
require 'veritrans/events'
require 'rails'
require 'webmock/rspec'
require 'vcr'

require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'capybara/poltergeist'
require 'active_support/testing/stream'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    js_errors: false,
    # phantomjs don't much like ssl of cloudfront.net
    phantomjs_options: %w[--ignore-ssl-errors=yes --ssl-protocol=any]
    # logger: STDOUT
  )
end

Capybara.configure do |config|
  config.javascript_driver = :poltergeist
  config.default_driver = :poltergeist
  config.run_server = false
end

GEM_ROOT = File.expand_path('..', __dir__)
ENV['RAILS_ENV'] = 'development'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures'
  c.hook_into :webmock # or :fakeweb
  # c.debug_logger = STDOUT
end

module SpecHelper
  def show_image
    Capybara::Screenshot.screenshot_and_open_image
  end
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.expect_with :rspec do |c|
    c.syntax = %i[should expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = %i[should expect]
  end

  config.around(:each) do |example|
    if example.metadata[:vcr] === false
      WebMock.allow_net_connect!
      VCR.turned_off { example.run }
      WebMock.disable_net_connect!
    else
      example.run
    end
  end
  config.include(SpecHelper)
end
