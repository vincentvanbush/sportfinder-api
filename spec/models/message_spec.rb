require 'spec_helper'

describe Message do
  subject { message }

  describe '.after' do
    before do
      @now = DateTime.now
      @event = FactoryGirl.create :event
      4.times do |i|
        FactoryGirl.create :message,
                           event: @event,
                           created_at: @now + i.minutes,
                           updated_at: @now + i.minutes
      end
    end

    it 'returns the messages created after the specified datetime' do
      after = @event.messages[2].created_at.to_i
      expected_messages = [@event.messages[2], @event.messages[3]]
      expect(@event.messages.after((@now + 2.minutes).to_i)).to match_array(expected_messages)
    end
  end
end
