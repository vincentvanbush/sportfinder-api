class Api::V1::SessionsController < ApplicationController
	before_action :authenticate_with_token!, only: [:destroy]

	# keys in session:
	# email, password
	# provider - e.g. 'facebook', 'tweeter'
	# provider_id
	# provider_token

	def create
		if params[:session][:provider] == 'facebook'
			
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
				byebug
				if user.save
					sign_in user, store: false
					user.generate_authentication_token!
					user.save
					render json: user, status: 200, location: [:api, user]	
				else
					render json: { errors: user.errors }, status: 422
				end
			end
			
		elsif params[:session][:provider] == 'tweeter'
		else
			byebug
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
		byebug
		current_user.generate_authentication_token!
		current_user.save
		head 204
	end
end
