require 'bundler/setup'

$:.push(File.expand_path("../../lib", __FILE__))

require 'rspec'
require 'veritrans'
require 'veritrans/cli'
require 'veritrans/events'
require 'rails'
require 'webmock/rspec'
require 'vcr'

GEM_ROOT = File.expand_path("../..", __FILE__)
ENV['RAILS_ENV'] = 'development'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures'
  c.hook_into :webmock # or :fakeweb
  #c.debug_logger = STDOUT
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
