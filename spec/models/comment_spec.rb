require 'spec_helper'

describe Comment do
  describe 'comment added on top of the last one by same user' do
    let(:comment) { FactoryGirl.create :comment }
    let(:same_user_comment) { FactoryGirl.build(:comment, event: comment.event, user: comment.user) }
    let(:other_user_comment) { FactoryGirl.build(:comment, event: comment.event) }

    it { expect(same_user_comment).not_to be_valid }
    it { expect(other_user_comment).to be_valid }
  end
end
