require 'spec_helper'

describe User do
  before { @user = FactoryGirl.build(:user) }

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_confirmation_of(:password) }
  it { should allow_value('example@domain.com').for(:email) }

  it { should be_valid }

  describe 'vote methods' do
    let(:user) { FactoryGirl.create :user }
    let(:event1) { FactoryGirl.create :event, user: user }
    let(:event2) { FactoryGirl.create :event, user: user }
    before do
      6.times { FactoryGirl.create :vote, event: event1, positive?: true }
      3.times { FactoryGirl.create :vote, event: event2, positive?: false }
    end

    it '.votes_for should list all votes for (not created by) the user' do
      expect(user.votes_for.count).to eql(9)
    end

    it '.positive_votes should be equal to the number of positive votes' do
      expect(user.positive_votes).to eql(6)
    end

    it '.negative_votes should be equal to the number of negative votes' do
      expect(user.negative_votes).to eql(3)
    end
  end


  it { should respond_to(:auth_token) }
  it { should validate_uniqueness_of(:auth_token) }

  describe '#generate_authentication_token!' do
    it 'generates a unique token' do
      Devise.stub(:friendly_token).and_return("auniquetoken123")
      @user.generate_authentication_token!
      expect(@user.auth_token).to eql "auniquetoken123"
    end

    it 'generates another token when one already has been taken' do
      existing_user = FactoryGirl.create(:user, auth_token: "auniquetoken123")
      @user.generate_authentication_token!
      expect(@user.auth_token).not_to eql existing_user.auth_token
    end
  end
end
