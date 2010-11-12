$:.unshift File.join(File.dirname(__FILE__), '..')
require 'app'
require 'test/spec'
require 'rack/test'

Test::Unit::TestCase.send :include, Rack::Test::Methods

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.auto_upgrade!
