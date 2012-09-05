# http://mattsears.com/articles/2011/12/10/minitest-quick-reference
require 'minitest/spec'
require 'minitest/autorun'
require 'turn'

Turn.config do |c|
 c.format  = :dotted
 c.natural = true
 c.trace   = 2
end

unless defined?(SPEC_HELPER_LOADED)
  SPEC_HELPER_LOADED = true
  require "rubygems"
  require "veritrans"
end
