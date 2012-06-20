$:.unshift File.dirname(__FILE__)

# Required gems
require 'rubygems'
require 'digest/sha2'
require "addressable/uri"
require 'faraday'


module VT
end

require 'veritrans/hash_generator'
require 'veritrans/demo_data'
require 'veritrans/post_data'
require 'veritrans/config'
require 'veritrans/client'
require 'veritrans/demo_client'
