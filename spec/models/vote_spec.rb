require 'spec_helper'

describe Vote do
  let(:vote) { FactoryGirl.create :vote }

  describe 'created for the same user and event as an existing one' do
    let(:another_vote) { FactoryGirl.build :vote, user: vote.user, event: vote.event }
    subject { another_vote }
    it { should_not be_valid }
  end

  describe 'created for the same user as an existing one' do
    let(:another_vote) { FactoryGirl.build :vote, user: vote.user }
    subject { another_vote }
    it { should be_valid }
  end

  describe 'created for the same event as an existing one' do
    let(:another_vote) { FactoryGirl.build :vote, event: vote.event }
    subject { another_vote }
    it { should be_valid }
  end
end
