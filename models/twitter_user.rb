require 'dm-core'

module TwitBlockr
  class Twit
	include DataMapper::Resource

	property :username, String, :key => true

	property :blocked_count, Integer, :default => 0

	property :updated_at, DateTime

  end
end
