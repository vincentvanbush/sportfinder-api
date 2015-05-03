require 'spec_helper'

describe Api::V1::UsersController, type: :controller do
  before(:each) { request.headers['Accept'] = "application/vnd.marketplace.v1" }

  describe "GET #show" do

    context "for an user that exists" do

      before(:each) do
        @user = FactoryGirl.create :user
        get :show, id: @user.id, format: :json
      end

      it "returns the information about a reporter on a hash" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eql @user.email
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
end
