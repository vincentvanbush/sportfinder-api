require 'spec_helper'

describe Comment do
  describe 'comment added on top of the last one by same user' do
    let(:comment) { FactoryGirl.create :comment }
    let(:same_user_comment) { FactoryGirl.build(:comment, event: comment.event, user: comment.user) }
    let(:other_user_comment) { FactoryGirl.build(:comment, event: comment.event) }

    it { expect(same_user_comment).not_to be_valid }
    it { expect(other_user_comment).to be_valid }
  end

  describe '.after' do
    subject { comment }
    before do
      @now = DateTime.now
      @event = FactoryGirl.create :event
      4.times do |i|
        FactoryGirl.create :comment,
                           event: @event,
                           created_at: @now + i.minutes,
                           updated_at: @now + i.minutes
      end
    end

    it 'returns the messages created after the specified datetime' do
      after = @event.comments[2].created_at.to_i
      expected_comments = [@event.comments[2], @event.comments[3]]
      expect(@event.comments.after((@now + 2.minutes).to_i)).to match_array(expected_comments)
    end
  end
end
