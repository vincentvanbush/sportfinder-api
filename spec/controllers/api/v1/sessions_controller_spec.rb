require 'spec_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do

	describe "POST #create" do
		context "when login through facebook" do
			context "user is in the database" do
				before(:each) do
					@user = FactoryGirl.build :user
					@user.facebook_id = "640749522677868" 
					@user.save
					credentials = { provider: "facebook", provider_token: "CAACEdEose0cBAI1aa6ZAPgMUZBCGSZBu3TOMcTqHHtkQADZAJuZBvPIGuKRBW1oRbZBj6qhmH1ACykkPQ5YESxcJ43cA3zT70WelgVBiX7iZBvEA8XcylKEZAMk7HTugvt3ScQX9SZBC64YtIVtoIENUZCTsoMzByTpU0kp7nHMe7SimtUJVxqZALWZAf4VBZAZCDXFA2nL70oRFWxJZAwgjiqIAyq2A4SY2YfvkuoZD" }
					post :create, { session: credentials }
				end

				it "returns the user record corresponding to the given credentials" do
					@user.reload
					expect(json_response[:user][:auth_token]).to eql @user.auth_token
				end
			end

			context "there is no user in the database" do
				before(:each) do
					credentials = { provider: "facebook", provider_token: "CAACEdEose0cBAI1aa6ZAPgMUZBCGSZBu3TOMcTqHHtkQADZAJuZBvPIGuKRBW1oRbZBj6qhmH1ACykkPQ5YESxcJ43cA3zT70WelgVBiX7iZBvEA8XcylKEZAMk7HTugvt3ScQX9SZBC64YtIVtoIENUZCTsoMzByTpU0kp7nHMe7SimtUJVxqZALWZAf4VBZAZCDXFA2nL70oRFWxJZAwgjiqIAyq2A4SY2YfvkuoZD" }
					post :create, { session: credentials }
				end

				it "returns the new user record" do
					expect(json_response[:user][:auth_token]).not_to be_empty
				end
			end
		end

		context "when custom login" do
			before(:each) do
				@user = FactoryGirl.create :user
			end

			context "when credentials are correct" do
				before(:each) do 
					credentials = { email: @user.email, password: "12345678" }
					# byebug
					post :create, { session: credentials }
				end

				it "returns the user record corresponding to the given credentials" do
					@user.reload
					expect(json_response[:user][:auth_token]).to eql @user.auth_token
				end

				it { should respond_with 200 }
			end

			context "when credentials are incorrect" do
				before(:each) do 
					credentials = { email: @user.email, password: "invalid" }
					post :create, { session: credentials }
				end

				it "returns a json with an error" do
					expect(json_response[:errors]).to eql "Invalid email or password"
				end

				it { should respond_with 422 } 
			end
		end
	end

	describe 'DELETE #destroy' do 
		before(:each) do
			@user = FactoryGirl.create :user
			sign_in @user#, store: false
			delete :destroy, id: @user.auth_token
		end

		it { should respond_with 204 }
	end
end
