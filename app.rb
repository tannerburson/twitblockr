$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'sinatra', 'lib')
$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'rack-test', 'lib')
$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'rack', 'lib')
$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'sinatra/base'
require 'beanstalk-client'
require 'twitter_oauth'

Dir['vendor/sinatra-plugins/*.rb'].each do |p|
  require p
end

Dir['models/*.rb'].each do |m|
  require m
end

require 'twitblockr-web'
