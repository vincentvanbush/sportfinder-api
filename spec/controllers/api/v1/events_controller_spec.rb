require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller do
  describe 'GET #show' do
    context "for an event that exists" do
      before(:each) do
        @event = FactoryGirl.create :event
        get :show, discipline_id: @event.discipline.slug, id: @event.slug
      end

      it "returns the information about the event on a hash" do
        user_response = json_response
        expect(user_response[:event][:title]).to eql @event.title
      end

      it { should respond_with 200 }
    end

    context "for a nonexistent event" do
      before do
        discipline = FactoryGirl.create :discipline
        get :show, discipline_id: discipline.slug, id: 'blablablabla'
      end

      it { should respond_with 404 }
    end

    context "for a nonexistent discipline" do
      before { get :show, discipline_id: 'blablbbalbalbal', id: 'abllabla' }
      it { should respond_with 404 }
    end
  end

  describe 'GET #index' do
    context 'for a discipline that exists' do
      before do
        @discipline = FactoryGirl.create :discipline
        5.times { FactoryGirl.create :event, discipline: @discipline }
        get :index, discipline_id: @discipline.slug
      end

      it "returns all events" do
        user_response = json_response
        expect(user_response[:events]).to have_exactly(5).items
      end

      it { should respond_with 200 }
    end

    context 'for a nonexistent discipline' do
      before { get :index, discipline_id: 'blablbbalbalbal' }
      it { should respond_with 404 }
    end
  end
end