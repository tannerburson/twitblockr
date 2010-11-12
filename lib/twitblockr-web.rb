require 'twitblockr'
require 'json'

module TwitBlockr
  module Web
    class Application < Sinatra::Base
      helpers Sinatra::MethodAbsorber, 
                      Sinatra::RenderPartial,
                      Sinatra::SessionAuth,
                      Sinatra::Plugins::ErrorHelpers
      use Rack::Flash
      set :twitter_key, ''
      set :twitter_secret, ''
      set :static, true
      set :public, File.join(File.dirname(__FILE__), '..', 'public')
      enable :sessions

      helpers do
        def hostname
          self.options.hostname
        end

        def action_for(score)
          TwitBlockr.action_for(score).to_s
        end

        def errors_on(obj)
          flash[:error] = {}
          flash[:error][:object] = obj
          flash[:error][:errors] = obj.errors
        end

        def summarize(text)
          pos = (text =~ /\n/)
          text[0..pos]
        end
      end

      before do
        @user = User.get(session[:user]) unless session[:user].nil?
        @client = TwitterOAuth::Client.new(
          :consumer_key => self.options.twitter_key,
          :consumer_secret => self.options.twitter_secret,
          :token => session[:access_token],
          :secret => session[:secret_token]
        )
        @rate_limit_status = @client.rate_limit_status
      end

      get '/' do
        redirect '/activity' unless @user.nil?
        erb :index
      end

      get '/connect' do
        request_token = @client.request_token(:oauth_callback => 'http://' + hostname + '/oauth_complete')
        session[:request_token] = request_token.token
        session[:request_token_secret] = request_token.secret
        redirect request_token.authorize_url.gsub('authorize', 'authenticate') 
      end

      get '/disconnect' do
        session[:user] = nil
        session[:request_token] = nil
        session[:request_token_secret] = nil
        session[:access_token] = nil
        session[:secret_token] = nil
        redirect '/'
      end

      get '/oauth_complete' do
        # Exchange the request token for an access token.
        @access_token = @client.authorize(
          session[:request_token],
          session[:request_token_secret],
          :oauth_verifier => params[:oauth_verifier]
        )
        
        if @client.authorized?
          # Storing the access tokens so we don't have to go back to Twitter again
          session[:access_token] = @access_token.token
          session[:secret_token] = @access_token.secret
          tuser = @client.info
          user = User.get tuser["id"]
          if user.nil?
            user = User.create({:id => tuser["id"],
                                :username => tuser["screenname"], 
                                :key_hash => User.generate_key
                              }) 
            raise "Failed saving OAuth user #{user.id.to_s}: #{user.errors.join('\n')}" if(!user.valid?(:setup))
          end
          user.access_key = @access_token.token
          user.access_secret = @access_token.secret
          user.save
          session[:user] = user.id
          redirect '/profile' if user.email.nil?
          redirect '/activity'
        else
          erb :error, {}, {:message => 'Twitter says you failed to autenticate. Try again! If this continues to happen, let us know!'}
        end
      end

      get '/profile' do
          erb :profile, {}, {:user => @user}
      end

      post '/profile' do
        @user.email = params[:email]
        @user.digest = !params[:digest].nil?
        @user.realtime = !params[:realtime].nil?
        @user.autofollow = true if params[:autofollow]
        if @user.valid? && @user.save
          flash[:message] = "Settings saved successfully"
        else
          flash[:message] = "There was an error saving settings"
          errors_on(@user)
        end
        erb :profile, {}, {:user => @user }
      end

      get '/activity' do
        redirect '/' if @user.nil?
        list =  @user.log_entries
        erb :activity, {}, { :user => @user, :list => list }
      end

      get '/score/:name' do |username|
        score, failures = ScoreKeeper.score(username)
        erb :check, {}, {:user=>username,:score=>score,:failures=>failures}
      end

      error do
        erb :error, {}, {:message => request.env['sinatra.error']}
      end
    end
  end
end
