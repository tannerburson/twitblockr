require 'app'
require 'test/spec'
require 'mocha'
require 'lib/twitblockr'

module TwitBlockr
  describe 'ScoreKeeper' do
    it 'should exist' do
      assert defined?('ScoreKeeper')
    end

    it 'should raise an error if twitter client is not authorized' do
      client = mock()
	  Tweep = Struct.new(:verified,:friends_count,:followers_count,
						 :friends_count,:statuses_count,:description, 
						 :created_at, :status)
	  tweep = Tweep.new(false, 0, 1, 1, 2, "Bio", "10/1/2006", nil)
	  sk = ScoreKeeper.new(client)
	  res = sk.score('screenname',tweep)
	  res.first.should.be 0
    end

  end
end
