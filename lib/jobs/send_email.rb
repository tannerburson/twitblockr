require 'job'
require 'tmail'
require 'pony'
require 'twitter_oauth'

module TwitBlockr
  class HashMismatchException < JobException;end;
  class InvalidUserCredentials < JobException;end;

  class SendEmailJob < Job

    def process(logid)
      user = User.get @job.ybody[:user]
      entry = LogEntry.get logid
      return false if !user.realtime
      action = case entry.entry_type.to_sym
               when :watch; "recommend watching"
               when :leave; "allowed"
               when :block; "blocked"
               end
      to = user.email
      subject = "Follower Message from TwitBlockr"
      from = "Follower-Messages@twitblockr.naturalzesty.com"
      message = <<-EOS
      <h3>A message from <font color="#f00">Twit</font>Blockr</h3>
      <p>We received notification that <a href="http://twitblockr.naturalzesty.com/score/#{entry.follower}">#{entry.follower}</a> has begun following you.</p>
      <p>We #{action} them for having a score of #{entry.score}.</p>
      <br/><br/>
      <p>If you no longer want to receive these messages, please login to <a href="http://twitblockr.naturalzesty.com">TwitBlockr</a> and change your email delivery settings.</p>
      EOS
      body = message
      Pony.mail(:to => to, :from => from, :subject => subject, :body => body, :content_type => 'text/html')
      return true
    end
  end
end
