class Api::V1::SessionsController < ApplicationController
	before_action :authenticate_with_token!, only: [:destroy]

	# keys in session:
	# email, password
	# provider - e.g. 'facebook', 'tweeter'
	# provider_id
	# provider_token

	def create
		if params[:session][:provider] == 'facebook'
			begin
				@facebook = Koala::Facebook::API.new(params[:session][:provider_token])
				profile = @facebook.get_object("me")

				if User.where(facebook_id: profile["id"]).exists?
					user = User.find_by(facebook_id: profile["id"])
					sign_in user, store: false
					user.generate_authentication_token!
					user.save
					render json: user, status: 200, location: [:api, user]
				else
					credentials = {}
					credentials[:email] = profile["email"]
					credentials[:facebook_id] = profile["id"]
					credentials[:password] = SecureRandom.base64
					credentials[:password_confirmation] = credentials[:password]
					user = User.new(credentials)
					if user.save
						sign_in user, store: false
						user.generate_authentication_token!
						user.save
						render json: user, status: 200, location: [:api, user]	
					else
						render json: { errors: user.errors }, status: 422
					end
				end
			rescue Koala::Facebook::AuthenticationError
				render json: { errors: "Facebook authentication failed" }, status: 422
			end
			
		elsif params[:session][:provider] == 'twitter'

			# byebug
			# a_t = ENV["CONSUMER_KEY"]
			# a_s = ENV["CONSUMER_SECRET"]
			# access_token = prepare_access_token(a_t, a_s)
			# response = access_token.request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json")
			# render json: response.body, status: 200
			
			begin
				client = Twitter::REST::Client.new do |config|
				  config.consumer_key        = ENV["CONSUMER_KEY"]
				  config.consumer_secret     = ENV["CONSUMER_SECRET"]
				  config.access_token        = params[:session][:provider_token]
				  config.access_token_secret = params[:session][:provider_secret]
				end
				twitter_id = client.access_token.scan(/\w+/)[0].to_i
				# twitter_id = params[:session][:twitter_id].to_i

				twitter_screen_name = client.user(twitter_id).screen_name

				if User.where(twitter_id: twitter_id).exists?
					user = User.find_by(twitter_id: twitter_id)
					sign_in user, store: false
					user.generate_authentication_token!
					user.save
					render json: user, status: 200, location: [:api, user]
				else
					credentials = {}
					email = twitter_screen_name + "@twitter.com"
					credentials[:email] = email
					credentials[:twitter_id] = twitter_id
					credentials[:password] = SecureRandom.base64
					credentials[:password_confirmation] = credentials[:password]
					user = User.new(credentials)
					if user.save
						sign_in user, store: false
						user.generate_authentication_token!
						user.save
						render json: user, status: 200, location: [:api, user]
					else
						render json: { errors: user.errors }, status: 422
					end
				end
			rescue Twitter::Error::Unauthorized	
				render json: { errors: "Twitter authentication failed" }, status: 422
			end
		else
			user_password = params[:session][:password]
			user_email = params[:session][:email]
			user = user_email.present? && User.find_by(email: user_email)

			if user.valid_password? user_password
				sign_in user, store: false
				user.generate_authentication_token!
				user.save
				render json: user, status: 200, location: [:api, user]
			else
				render json: { errors: "Invalid email or password" }, status: 422
			end
		end
	end

	def destroy

		# user = User.find_by(auth_token: params[:id])
		# user.generate_authentication_token!
		# user.save
		current_user.generate_authentication_token!
		current_user.save
		head 204
	end


	# def prepare_access_token(oauth_token, oauth_token_secret)
	# 	consumer = OAuth::Consumer.new(ENV["CONSUMER_KEY"], ENV["CONSUMER_SECRET"], { :site => "https://api.twitter.com" })
	# 	token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
 #    	access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
 
 #    	return access_token
	# end
end
