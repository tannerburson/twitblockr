#!/usr/env ruby
require 'rubygems'
require 'json'
require 'beanstalk-client'
require 'syslog'
require 'tmail'

BEANSTALK = Beanstalk::Pool.new(['localhost:11300'])

str = ''
ARGF.each do |line|
  str << line
end
message = TMail::Mail.parse(str.strip)
twitter_header = message.header_string("X-Twitteremailtype")
case twitter_header
when "is_following"
  data = {:type => :email_follow, :message => str }
  BEANSTALK.yput data
when "direct_message"
end
Syslog.open('twitblockr', Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_USER)
Syslog.log(Syslog::LOG_INFO, "#{message.to.join(' ')} from #{message.from.to_s}, SUBJECT: #{message.subject.to_s}")
Syslog.close
