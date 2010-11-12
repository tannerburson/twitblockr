require 'twitter_oauth'

module TwitBlockr

  class TwitterError < StandardError;end;
  class TwitBlockr

    def initialize(client)
      @client = client
      raise 'Client not authorized' unless @client.authorized?
    end

    def block(twit)
      result = @client.block(twit)
      if !result['screen_name'].nil?
        u = Twit.get(twit)
        u = Twit.create(:username => twit) if u.nil?
        u.blocked_count += 1
        u.save
        return true
      end
      return false
    end

    def action_for(score)
      TwitBlockr.action_for(score)
    end

    def self.action_for(score)
      case score
      when -100..2
        :leave
      when 3..4
        :watch
      else
        :block
      end
    end
  end

  class ScoreKeeper

    def initialize(client=nil)
      @client = client
      @client ||= TwitterOAuth::Client.new
      setup_rules
    end

    def self.score(username, tweep=nil)
      twib = self.new
      return twib.score(username, tweep)
    end

    def score(username,tweep=nil)
      username.downcase!
      tweep ||= @client.show(username)
      if !tweep['error'].nil?
        raise TwitterError.new(tweep["error"])
      end
      return ScoreCalculator.new(tweep,@rules).calculate
    end

    def count_links_in_updates(updates)
      links = updates.inject(0) do |sum,s|
        if s.text =~ /https?:\/\//
          sum + 1
        else
          sum
        end
      end
      links
    end

    def setup_rules
      @rules = [
        Rule.new("Verified Account",-3) do |user|
          puts user.inspect
          true if user['verified']
        end,
        Rule.new("Following Count > 150",1) do |user|
          true if user['friends_count'] > 150
        end,

        Rule.new("Follower Ratio < 0.5",1) do |user|
          true if ((user['followers_count'].to_f / user['friends_count'].to_f) < 0.5)
        end,

        Rule.new("Follower Ratio > 1",-2) do |user|
          true if ((user['followers_count'].to_f / user['friends_count'].to_f) >= 1.0) and user['followers_count'] > 5
        end,

        Rule.new("Update Count <= 1",2) do |user|
          true if user['statuses_count'] <= 1
        end,

        Rule.new("Bio is empty",1) do |user|
          true if user['description'].nil?
        end,

        Rule.new("Account is less than a week old",1) do |user|
          true if ((Date.today - Date.parse(user['created_at'])) <=7)
        end,

        Rule.new("Has more than one update",1) do |user|
          true if user['statuses_count'] <=1
        end,

        Rule.new("Last status included a link",1) do |user|
          true if !user['status'].nil? && user['status']['text'] =~ %r{https?://}
        end,

        Rule.new("Last status hit keyword trap for words:",1) do |user,rule|
          result = false
          unless user['status'].nil?
            ['sex','follower','money', 'free', 
            'eca.sh','survey', 'for sale'].each do |keyword|
              if user['status']['text'].downcase =~ /#{keyword}/
                rule.score += 1
                result = true
                rule.name << " #{keyword}"
              end
            end 
          end
          result
        end,

        #Rule.new("Has been blocked over 10 times",2) do |user|
        #  true if user.blocked_count > 10
        #end
      ]
    end
  end
end
