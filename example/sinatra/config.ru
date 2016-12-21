#!/usr/bin/env ruby

# This file is for running on heroku

require './sinatra'
Sinatra::Application.run!

require ::File.expand_path("./cable/config/environment", __FILE__)
run Rails.application
