require 'app'
require 'test/spec'
require 'mocha'
require 'lib/twitblockr'

module TwitBlockr
  describe 'TwitBlocker Object' do
    it 'should exist' do
      assert defined?('TwitBlocker')
    end

    it 'should raise an error if twitter client is not authorized' do
      client = mock()
	  client.expects(:authorized?).once
      should.raise {
        TwitBlockr.new(client)
      }
    end

	it 'should return true if a twit was blocked' do
	  client = mock()
	  result = stub(:screen_name => 'screenname')
	  client.stubs(:authorized?).returns(true)
	  client.stubs(:block).returns(result)
	  Twit.stubs(:get).returns(nil)
	  t = TwitBlockr.new(client)
	  t.block('screenname').should.be true
	end

	it 'should return false if a twit was not found' do
	  client = mock()
	  result = stub(:screen_name => nil)
	  client.stubs(:authorized?).returns(true)
	  client.stubs(:block).returns(result)
	  Twit.stubs(:get).returns(nil)
	  t = TwitBlockr.new(client)
	  t.block('screnname').should.be false
	end

  end
end
