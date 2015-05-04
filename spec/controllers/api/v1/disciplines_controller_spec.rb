require 'rails_helper'

RSpec.describe Api::V1::DisciplinesController, type: :controller do
  describe "GET #show" do
    context "for a discipline that exists (by slug)" do
      before(:each) do
        @discipline = FactoryGirl.create :discipline
        get :show, id: @discipline.slug
      end

      it "returns the information about a reporter on a hash" do
        user_response = json_response
        expect(user_response[:discipline][:title]).to eql @discipline.title
      end

      it { should respond_with 200 }
    end

    context "for a nonexistent discipline" do
      before(:each) do
        get :show, id: 'blablablabla'
      end

      it { should respond_with 404 }
    end
  end
end
