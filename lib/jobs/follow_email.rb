require 'job'
require 'tmail'
require 'twitter_oauth'

module TwitBlockr
  class HashMismatchException < JobException;end;
  class InvalidUserCredentials < JobException;end;

  class FollowEmailJob < Job

    def twitter_auth(user)
      @client = TwitterOAuth::Client.new(:consumer_key => '',
                                        :consumer_secret => '',
                                        :token => user.access_key,
                                        :secret => user.access_secret)
      if !@client.authorized?
        debug "user #{user.id} failed to authenticate" 
        user.log_activity(:error,"Twitter credentials have expired.  Please Sign in to TwitBlockr again.")
        raise InvalidUserCredentials
      end

    end

    def parse_email(data)
      message = TMail::Mail.parse(data.strip)
      # We use the 'account' portion of the email address
      # as part of a unique identifier for a given user
      user_key = message.to.first.split(/@/).first
      user_id = message.header_string("X-Twitterrecipientid")
      follower = message.header_string("X-Twittersenderscreenname")
      # Match the key with the twitter id
      user = User.first( :key_hash => user_key, :id => user_id )
      if user.nil?
        debug "user #{user_id} not found with hash #{user_key}" 
        raise HashMismatchException
      end
      return follower,user
    end

    def process(data)
      # Parse the user and follower info from the mail data
      follower, user = parse_email(data)
      # Auth against twitter using the user's credentials
      twitter_auth(user)

      tb = TwitBlockr.new(@client)
      sk = ScoreKeeper.new(@client)

      debug follower
      # Get the score and a list of rule results for the current follower
      score, failures = sk.score(follower)
      debug score.to_s
      debug failures.inspect

      # Ask TwitBlockr for the appropriate action to take
      case tb.action_for(score)
      when :block
        debug "Block"
        tb.block(follower)
        message = "Blocked #{follower} for having a score of #{score}.\n Violated Rules: \n#{failures.join("\n")}"
        entry_id = user.log_activity(:block,message,follower,score,failures.join('|'))
        @queue.yput({:type => :realtime_send, :message => message, :user => user.id, :entry_id => entry_id})
      when :watch
        debug "Watch"
        message = "Recommend watching #{follower} for having a score of #{score}.\n Violated Rules: \n#{failures.join("\n")}"
        entry_id = user.log_activity(:watch,message,follower,score,failures.join('|'))
        @queue.yput({:type => :realtime_send, :message => message, :user => user.id, :entry_id => entry_id})
      when :leave
        debug "Leave"
        message = "Allowed follower #{follower} for having a score of #{score}.\n Violated Rules: \n#{failures.join("\n")}"
        entry_id = user.log_activity(:leave,message,follower,score,failures.join('|'))
        @queue.yput({:type => :realtime_send, :message => message, :user => user.id, :entry_id => entry_id})
        @queue.yput({:type => :follow_back, :data => follower, :user => user.id}) if user.autofollow
      end
      return true
    end
  end
end
