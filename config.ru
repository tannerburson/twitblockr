#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'app.rb')

TwitBlockr::Web::Application.configure :development do|app|
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/twitblockr.sqlite3")
    DataMapper.auto_upgrade!
	BEANSTALK = Beanstalk::Pool.new(['localhost:11300'])
	app.set :hostname, "localhost:4567"
end

TwitBlockr::Web::Application.configure :production do |app|
	DataMapper.setup(:default, "mysql://twitblockr:twitblockr@localhost/twitblockr")
    DataMapper.auto_upgrade!
	BEANSTALK = Beanstalk::Pool.new(['localhost:11300'])
	app.set :hostname, "twitblockr.naturalzesty.com"
end

map '/' do
	run TwitBlockr::Web::Application
end
