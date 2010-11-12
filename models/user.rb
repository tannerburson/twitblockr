require 'dm-core'
require 'time'
require 'digest/md5'

module TwitBlockr
  class User
    include DataMapper::Resource

    property :id, Integer, :key => true

    property :username, String

    property :email, String, :format => :email_address, :nullable => true
    validates_present :email, :when => [:default]
    validates_absent :email, :when => [:setup]

    property :access_key, String

    property :access_secret, String

    property :key_hash,  String

    property :digest, Boolean, :default => true

    property :realtime, Boolean, :default => false

    property :autofollow, Boolean, :default => false

    property :updated_at, DateTime

    has n, :log_entries, :model => 'LogEntry', :order => [ :created_at.desc ]

    def self.generate_key(num=rand(20000))
      key = (Time.now.to_i * num / 12).to_s(36)
      u = self.first(:key_hash => key)
      return key if u.nil?
      return self.generate_key if !u.nil?
    end

    def log_activity(type,data,follower=nil,score=nil,failures=nil)
      entry = self.log_entries.new(:data => data, :entry_type => type.to_s, :score=>score,:follower=>follower,:rule_results=>failures)
      entry.save
      entry.id
    end
  end
end
