require 'rails_helper'

RSpec.describe Api::V1::CommentsController, type: :controller do
  let(:event) { FactoryGirl.create :event }
  let(:comment_attributes) { FactoryGirl.attributes_for :comment }
  let(:user) { FactoryGirl.create :user }

  describe "POST #create" do

    before(:each) do
      api_authorization_header user.auth_token
    end

    context 'when successfully created' do
      before do
        post :create,
             comment: comment_attributes,
             discipline_id: event.discipline.slug,
             event_id: event.slug,
             user_id: user.id
      end

      it { should respond_with 201 }
    end

    context 'when not created' do
      context 'due to validation errors' do
        before do
          comment_attributes[:content] = nil
          post :create,
               comment: comment_attributes,
               discipline_id: event.discipline.slug,
               event_id: event.slug,
               user_id: user.id
        end

        it { should respond_with 422 }
      end

      context 'due to invalid path' do
        before do
          post :create,
               comment: comment_attributes,
               discipline_id: 789,
               event_id: 456,
               user_id: 123
        end
        it { should respond_with 404 }
      end
    end
  end

  describe "DELETE #destroy" do

    before(:each) do
      api_authorization_header user.auth_token
    end

    let(:comment) { FactoryGirl.create :comment }
    before { delete :destroy, { discipline_id: comment.event.discipline.slug,
                                event_id: comment.event.slug,
                                id: comment.id } }
    it { should respond_with 204 }
  end

  describe "GET #index" do

    before(:each) { api_authorization_header user.auth_token }

    let(:event) { FactoryGirl.create :event }
    before do
      now = DateTime.now
      5.times { |i| FactoryGirl.create :comment, event: event,
                                        created_at: now + i.hours,
                                        updated_at: now + i.hours }
    end

    context 'when is not receiving any time filter param' do
      before { get :index, discipline_id: event.discipline.slug, event_id: event.slug }

      it 'returns all comments of the event' do
        expect(json_response[:comments]).to have(5).items
      end
    end

    context 'with specified time filter' do
      let!(:after) { event.comments[2].created_at.to_i }
      before do
        get :index, discipline_id: event.discipline.slug, event_id: event.slug,
            after: after
      end

      it 'returns only comments after the time' do
        expected_contents = event.comments.after(after).collect { |m| m.content }
        actual_contents = json_response[:comments].collect { |m| m[:content] }
        expect(actual_contents).to match_array(expected_contents)
      end
    end
  end
end
