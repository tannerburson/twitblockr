$:.unshift File.join(File.dirname(__FILE__))
require 'rubygems'
require 'json'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'twitter_oauth'
require 'beanstalk-client'
require 'job'
require 'syslog'
require 'twitblockr'

DEBUG = TRUE

Dir['models/*.rb'].each do |m|
  require m
end

Dir['lib/jobs/*.rb'].each do |j|
  require j
end

if ARGV[1] == "dev"
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/twitblockr.sqlite3")
else
  DataMapper.setup(:default, "mysql://twitblockr:twitblockr@localhost/twitblockr")
end
DataMapper.auto_upgrade!
BEANSTALK = Beanstalk::Pool.new(['localhost:11300'])

puts "Starting up job..."
module TwitBlockr
loop do
  job = BEANSTALK.reserve
  data = job.ybody
  puts "Message Type: " + data[:type].to_s
  case data[:type]
  when :passthrough
    job.delete
  when :realtime_send
    puts "Sending an email"
    job_proc = SendEmailJob.new(BEANSTALK,job)
    begin
      res = job_proc.process(data[:entry_id])
    rescue
      Syslog.open('twitblockr', Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_USER){ |l|
        l.log(Syslog::LOG_INFO, "{#{job.id}} buried during :realtime_send. #{$!}")
      }
      job.bury
      next
    end
    puts "Sendmail result: " << res.to_s
    job.delete
  when :email_follow
    count = 0
    puts "Processing email"
    job_proc = FollowEmailJob.new(BEANSTALK,job)
    begin
      res = job_proc.process(data[:message])
    rescue HashMismatchException => e
      job.bury
      next
    rescue InvalidUserCredentials => e
      #TODO push a job to forward the failed message
    rescue TwitterError => e
      Syslog.open('twitblockr', Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_USER){ |l|
        l.log(Syslog::LOG_INFO, "{#{job.id}} deleted. #{e}")
      }
    rescue OAuth::Error => e
      count += 1
      retry if count < 3
    end
    job.delete
  else
    Syslog.open('twitblockr', Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_USER){ |l|
      l.log(Syslog::LOG_INFO,"BURY:{#{job.id}} #{data[:type]}")
    }
    job.bury
  end
end
end
