require 'rubygems'
require 'bundler'

Bundler.require

require './service'
run Rack::URLMap.new('/api/v1' => Sinatra::Application)