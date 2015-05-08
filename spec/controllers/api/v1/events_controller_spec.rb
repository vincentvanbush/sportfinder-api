require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller do
  describe 'GET #show' do
    context "for an event that exists" do
      before(:each) do
        @event = FactoryGirl.create :event
        3.times { c = FactoryGirl.create :comment, event: @event }
        get :show, discipline_id: @event.discipline.slug, id: @event.slug
      end

      it "returns the information about the event on a hash" do
        expect(json_response[:event][:title]).to eql @event.title
      end

      it 'nests the event\'s comments' do
        expect(json_response[:event]).to have_key(:comments)
        binding.pry
        expect(json_response[:event][:comments].count).to eql(3)
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
      let(:discipline) { FactoryGirl.create :discipline }
      before do
        5.times { FactoryGirl.create :event, discipline: discipline }
        get :index, discipline_id: discipline.slug
      end

      it "returns all events" do
        expect(json_response[:events]).to have_exactly(5).items
      end

      it 'contains pagination info' do
        get :index, discipline_id: discipline.slug, page: 1, per_page: 2
        expect(json_response[:events]).to have_exactly(2).items
        expect(json_response).to have_key(:meta)
        expect(json_response[:meta]).to have_key(:pagination)
        expect(json_response[:meta][:pagination][:per_page]).to eql("2") # fails for integer
        expect(json_response[:meta][:pagination][:total_pages]).to eql(3)
        expect(json_response[:meta][:pagination][:total_objects]).to eql(5)
      end

      it { should respond_with 200 }
    end

    context 'scoped' do
      let(:discipline) { FactoryGirl.create :discipline }
      before do
        2.times { FactoryGirl.create :event, discipline: discipline, finished?: true }
        3.times { FactoryGirl.create :event, discipline: discipline, finished?: false }
      end

      describe 'finished' do
        before { get :index, discipline_id: discipline.slug, finished: true }
        it 'returns 2 records' do
          expect(json_response[:events]).to have_exactly(2).items
        end
      end

      describe 'unfinished' do
        before { get :index, discipline_id: discipline.slug, finished: false }
        it 'returns 3 records' do
          expect(json_response[:events]).to have_exactly(3).items
        end
      end
    end

    context 'for a nonexistent discipline' do
      before { get :index, discipline_id: 'blablbbalbalbal' }
      it { should respond_with 404 }
    end

  end

  describe 'POST #create' do
    let(:user) { FactoryGirl.create :user }
    context 'when successfully created' do
      let(:discipline) { FactoryGirl.create :discipline, title: 'football' }
      let(:event_attributes) do
        team1 = { title: 'Arsenal', squad_members: ['Szczesny', 'Sanchez', 'Giroud']}
        team2 = { title: 'Liverpool', squad_members: ['Mignolet', 'Gerrard', 'Sterling']}
        FactoryGirl.attributes_for(:event)
                               .merge({ contenders: [team1, team2] })
      end
      before do
        post :create, { discipline_id: discipline.slug,
                        user_id: user.id,
                        event: event_attributes }
      end
      describe 'the json response' do
        it 'contains info for the created event' do
          expect(json_response[:event][:title]).to eql event_attributes[:title]
        end
        it 'nests info about contenders' do
          expect(json_response[:event]).to have_key(:contenders)
          expect(json_response[:event][:contenders].length).to eql(2)
          expect(json_response[:event][:contenders][0][:title]).to eql('Arsenal')
          expect(json_response[:event][:contenders][0][:squad_members]).to include('Szczesny')
        end
      end

      it { should respond_with 201 }
    end

    context 'when is not created' do
      context 'due to unknown discipline' do
        let(:unknown_discipline) { FactoryGirl.create :discipline, title: 'shitball' }
        let(:event_attributes) { FactoryGirl.attributes_for(:event) }
        before do
          post :create, { discipline_id: unknown_discipline.slug,
                          user_id: user.id,
                          event: event_attributes }
        end
        it { should respond_with 422 }
      end

      context 'due to nonexistent discipline' do
        let(:event_attributes) { FactoryGirl.attributes_for(:event) }
        before do
          post :create, { discipline_id: 'benis',
                          user_id: user.id,
                          event: event_attributes }
        end
        it { should respond_with 404 }
      end

      context 'due to validation errors' do
        let(:discipline) { FactoryGirl.create :discipline, title: 'football' }
        let(:user) { FactoryGirl.create :user }
        let(:event_attributes) { FactoryGirl.attributes_for(:event,
                                 title: nil,
                                 description: ['a'] * 500) }
        before do
          post :create, { discipline_id: discipline.slug,
                          user_id: user.id,
                          event: event_attributes }
        end

        it 'should contain error info' do
          expect(json_response).to have_key(:errors)
          expect(json_response[:errors]).to have_key(:title)
        end

        it { should respond_with 422 }
      end
    end
  end
end
