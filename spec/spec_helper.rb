require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/lib/generators/"
end

require 'minitest/spec'
require 'minitest/autorun'
require 'turn'

Turn.config do |c|
 c.format  = :dotted
 c.natural = true
 c.trace   = 2
end

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

unless defined?(SPEC_HELPER_LOADED)
  SPEC_HELPER_LOADED = true
  require "rubygems"
  require "veritrans"
end

