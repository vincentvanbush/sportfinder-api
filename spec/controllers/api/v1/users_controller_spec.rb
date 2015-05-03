require 'spec_helper'

describe Api::V1::UsersController, type: :controller do
  before(:each) { request.headers['Accept'] = "application/vnd.scorify.v1" }

  describe "GET #show" do

    context "for an user that exists" do

      before(:each) do
        @user = FactoryGirl.create :user
        get :show, id: @user.id, format: :json
      end

      it "returns the information about a reporter on a hash" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:user][:email]).to eql @user.email
      end

      it { should respond_with 200 }
    end

    context "for a nonexistent user" do

      before(:each) do
        get :show, id: 'blablablabla', format: :json
      end

      it { should respond_with 404 }
    end
  end

  context "when is successfully created" do
    before(:each) do
      @user_attributes = FactoryGirl.attributes_for :user
      print @user_attributes.to_json
      post :create, { user: @user_attributes }, format: :json
    end

    it "renders the json representation for the user record just created" do
      user_response = JSON.parse(response.body, symbolize_names: true)
      expect(user_response[:user][:email]).to eql @user_attributes[:email]
    end

    it { should respond_with 201 }
  end

  context "when is not created" do
    before(:each) do
      #notice I'm not including the email
      @invalid_user_attributes = { password: "12345678",
                                   password_confirmation: "12345678" }
      post :create, { user: @invalid_user_attributes }, format: :json
    end

    it "renders an errors json" do
      user_response = JSON.parse(response.body, symbolize_names: true)
      expect(user_response).to have_key(:errors)
    end

    it "renders the json errors on why the user could not be created" do
      user_response = JSON.parse(response.body, symbolize_names: true)
      expect(user_response[:errors][:email]).to include "can't be blank"
    end

    it { should respond_with 422 }
  end
end
