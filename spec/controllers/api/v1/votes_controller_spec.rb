require 'rails_helper'

RSpec.describe Api::V1::VotesController, type: :controller do
  let(:event) { FactoryGirl.create :event }
  let(:creator) { FactoryGirl.create :user }
  let(:positive_vote_attrs) { FactoryGirl.attributes_for :vote, positive?: true }
  let(:negative_vote_attrs) { FactoryGirl.attributes_for :vote, positive?: false }

  describe 'POST #create' do
    context 'when successfully created' do
      before do
        post :create, vote: positive_vote_attrs, discipline_id: event.discipline.slug,
             event_id: event.slug, user_id: creator.id
      end

      it { should respond_with 201 }
    end

    context 'when not created' do
      context 'due to invalid path' do
        before do
          post :create, vote: positive_vote_attrs, discipline_id: 123,
               event_id: 456, user_id: creator.id
        end
        it { should respond_with 404 }
      end

      context 'due to validation errors' do
        before do
          invalid_attrs = FactoryGirl.attributes_for :vote, positive?: nil
          post :create, vote: invalid_attrs, discipline_id: event.discipline.slug,
               event_id: event.slug, user_id: creator.id
        end
        it { should respond_with 422 }
      end
    end

    context 'when creating a number of votes' do
      before do
        5.times do
          user = FactoryGirl.create :user
          post :create, vote: positive_vote_attrs, discipline_id: event.discipline.slug,
               event_id: event.slug, user_id: user.id
        end
        3.times do
          user = FactoryGirl.create :user
          post :create, vote: negative_vote_attrs, discipline_id: event.discipline.slug,
               event_id: event.slug, user_id: user.id
        end
      end

      it { expect(event.positive_votes).to eql(5) }
      it { expect(event.negative_votes).to eql(3) }
    end
  end
end
