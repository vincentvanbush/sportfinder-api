require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller do
  describe 'GET #show' do
    context "for an event that exists" do
      before(:each) do
        @event = FactoryGirl.create :event
        3.times { c = FactoryGirl.create :comment, event: @event }
        4.times { FactoryGirl.create :vote, event: @event, positive?: true }
        2.times { FactoryGirl.create :vote, event: @event, positive?: false }
        get :show, discipline_id: @event.discipline.slug, id: @event.slug
      end

      it "returns the information about the event on a hash" do
        expect(json_response[:event][:title]).to eql @event.title
      end

      it 'nests the event\'s comments' do
        expect(json_response[:event]).to have_key(:comments)
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

    before(:each) do 
      api_authorization_header user.auth_token
    end
    
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

  describe 'PATCH #update' do
    let(:user) { FactoryGirl.create :user }

    before(:each) do 
      api_authorization_header user.auth_token
    end

    context 'when successfully updated' do  
      context 'plain values' do
        let(:discipline) { FactoryGirl.create :discipline, title: 'football' }
        let(:event) { FactoryGirl.create :event, discipline: discipline, user: user }
        let(:event_attributes) {{ title: "new_title", description: "new_description", finished: true }}

        before do
          patch :update, { discipline_id: discipline.slug,
                          user_id: user.id,
                          id: event.id,
                          event: event_attributes}
        end

        it 'contains updated info about event' do
          expect(json_response[:event][:title]).to eql "new_title"
          expect(json_response[:event][:description]).to eql "new_description"
          # line below solves problem of modifing finished? but event has key finished not finished? 
          # despite that in event_serializer is finished? Why?
          expect(json_response[:event][:finished]).to be true
        end

        it { should respond_with 201 }
      end
      
    end

    context 'when is not updated' do
      let(:discipline) { FactoryGirl.create :discipline, title: 'football' }
      let(:event) { FactoryGirl.create :event, discipline: discipline, user: user }

      context 'because of nonexistent' do
        context 'discipline' do
          before do
            patch :update, {  discipline_id: 'farafara', 
                              user_id: user.id,
                              id: event.id,
                              event: { title: 'just_a_title' }}
          end

          it { should respond_with 404 }
        end

        context 'event' do
          before do
            patch :update, {  discipline_id: discipline.id,
                              user_id: user.id,
                              id: 'fiki_miki',
                              event: { title: 'huehuehue' }}
          end

          it { should respond_with 404 }
        end
      end
               
      context 'because of validation errors' do
        context 'nil title' do
          let(:invalid_attrs) {{ title: nil, description: 'a' * 20 }}
          before do
            patch :update, {  discipline_id: discipline.id,
                              user_id: user.id,
                              id: event.id,
                              event: invalid_attrs }
          end

          it { should respond_with 422 }
        end

        context 'too long description' do
          let(:invalid_attrs) {{ title: 'valid title', description: 'a' * 201 }}
          before do
            patch :update, {  discipline_id: discipline.id,
                              user_id: user.id,
                              id: event.id,
                              event: invalid_attrs }
          end

          it { should respond_with 422 }
        end
      end
    end
  end
end
