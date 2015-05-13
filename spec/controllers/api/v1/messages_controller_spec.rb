require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do

  describe 'GET #index' do
    let(:event) { FactoryGirl.create :event }
    before do
      now = DateTime.now
      5.times do |i|
         FactoryGirl.create :message,
                            event: event,
                            created_at: now + i.hours,
                            updated_at: now + i.hours
      end
    end

    context 'when is not receiving any time filter parameter' do
      before { get :index, discipline_id: event.discipline.slug, event_id: event.slug }

      it 'returns all messages of the event' do
        expect(json_response[:messages]).to have(5).items
      end
    end

    context 'with specified time filter' do
      let!(:after) { event.messages[2].created_at.to_i }
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

  describe 'POST #create' do
    let(:message_attributes) { FactoryGirl.attributes_for :message }

    context 'when is successfully created' do
      let(:event) { FactoryGirl.create :event }
      before do
        post :create, message: message_attributes, discipline_id: event.discipline.slug, event_id: event.slug
      end

      it 'renders the json repr for the created message' do
        expect(json_response[:message][:content]).to eql message_attributes[:content]
      end

      it { should respond_with 201 }
    end

    context 'when is not created' do
      context 'because of nonexistent' do
        context 'discipline' do
          before do
            post :create, message: message_attributes, discipline_id: 'blablabla', event_id: 'asdf'
          end
          it { should respond_with 404 }
        end

        context 'event' do
          before do
            discipline = FactoryGirl.create :discipline
            post :create, message: message_attributes, discipline_id: discipline.slug, event_id: 'asdf'
          end
          it { should respond_with 404 }
        end
      end

      context 'becaue of validation errors' do
        let(:event) { FactoryGirl.create :event }
        let(:invalid_attrs) { {content: nil, attachment_url: 'a' * 300} }
        before do
          post :create, message: invalid_attrs, discipline_id: event.discipline.slug, event_id: event.slug
        end

        it "renders an errors json" do
          expect(json_response).to have_key(:errors)
          expect(json_response[:errors]).to have_key(:content)
          expect(json_response[:errors]).to have_key(:attachment_url)
        end

        it { should respond_with 422 }
      end
    end
  end

  describe 'PUT/PATCH #update' do
    let(:message) { FactoryGirl.create :message }
    context 'when is successfully updated' do
      before do
        patch :update, { discipline_id: message.event.discipline.slug,
                         event_id: message.event.slug,
                         id: message.id,
                         message: { content: 'New content' } }
      end

      it 'renders the json repr for the updated message' do
        expect(json_response[:message][:content]).to eql 'New content'
      end

      it { should respond_with 200 }
    end

    context 'when is not updated' do
      context 'because of nonexistent' do
        context 'discipline' do
          before do
            patch :update, { discipline_id: 'blabla',
                             event_id: 'benis',
                             id: 'fug',
                             message: { content: 'benis' } }
          end
          it { should respond_with 404 }
        end

        context 'event' do
          before do
            patch :update, { discipline_id: message.event.discipline.slug,
                             event_id: 'benis',
                             id: 'fug',
                             message: { content: 'benis' } }
          end
          it { should respond_with 404 }
        end

        context 'message' do
          before do
            patch :update, { discipline_id: message.event.discipline.slug,
                             event_id: message.event.slug,
                             id: 'fug',
                             message: { content: 'benis' } }
          end
          it { should respond_with 404 }
        end
      end

      context 'becaue of validation errors' do
        let(:invalid_attrs) { {content: nil, attachment_url: 'a' * 300} }
        before do
          patch :update, { discipline_id: message.event.discipline.slug,
                           event_id: message.event.slug,
                           id: message.id,
                           message: invalid_attrs }
        end

        it "renders an errors json" do
          expect(json_response).to have_key(:errors)
          expect(json_response[:errors]).to have_key(:content)
          expect(json_response[:errors]).to have_key(:attachment_url)
        end

        it { should respond_with 422 }
      end
    end

  end

  describe 'DELETE #destroy' do
    let(:message) { FactoryGirl.create :message }
    before { delete :destroy, { discipline_id: message.event.discipline.slug,
                                event_id: message.event.slug,
                                id: message.id } }
    it { should respond_with 204 }
  end
end
