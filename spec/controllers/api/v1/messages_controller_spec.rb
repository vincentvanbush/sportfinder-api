require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do

  describe 'GET #index' do
    let(:event) { FactoryGirl.create :event }
    let(:now) { DateTime.now }
    before do
      5.times do |i|
         FactoryGirl.create :message,
                            event: event,
                            created_at: now + i.minutes,
                            updated_at: now + i.minutes
      end
    end

    context 'when is not receiving any time filter parameter' do
      before { get :index, discipline_id: event.discipline.slug, event_id: event.slug }

      it 'returns all messages of the event' do
        expect(json_response[:messages]).to have(5).items
      end
    end

    context 'with specified time filter' do
      let(:after) { event.messages[2].created_at }
      before do
        get :index, discipline_id: event.discipline.slug, event_id: event.slug,
            after: after
      end

      it 'returns only messages after the time' do
        expected_contents = event.messages.after(after).collect { |m| m.content }
        actual_contents = json_response[:messages].collect { |m| m[:content] }
        expect(actual_contents).to match_array(expected_contents)
      end
    end

  end
end
