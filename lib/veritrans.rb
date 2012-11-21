$:.unshift File.dirname(__FILE__)

# Required gems
require 'rubygems'
require 'digest/sha2'
require "addressable/uri"
require 'faraday'

# root namespace 
module Veritrans
end

require 'veritrans/hash_generator'
require 'veritrans/post_data'
require 'veritrans/version'
require 'veritrans/config'
require 'veritrans/client'
require 'veritrans/v_t_direct'
require 'generators/install_generator.rb'