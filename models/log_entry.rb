require 'dm-core'
require 'time'

module TwitBlockr
  class LogEntry
    include DataMapper::Resource

    property :id,         Serial

    property :entry_type, String

    property :data,       Text

    property :follower,   String,     :nullable => true

    property :rule_results, Text,     :nullable => true

    property :score,      Integer,    :nullable => true
    property :created_at, DateTime

    belongs_to :user

  end
end
