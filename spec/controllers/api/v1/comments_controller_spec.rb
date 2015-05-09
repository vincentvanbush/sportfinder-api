require 'rails_helper'

RSpec.describe Api::V1::CommentsController, type: :controller do
  let(:event) { FactoryGirl.create :event }
  let(:comment_attributes) { FactoryGirl.attributes_for :comment }
  let(:user) { FactoryGirl.create :user }

  describe "POST #create" do
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
    let(:comment) { FactoryGirl.create :comment }
    before { delete :destroy, { discipline_id: comment.event.discipline.slug,
                                event_id: comment.event.slug,
                                id: comment.id } }
    it { should respond_with 204 }
  end
end
