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
