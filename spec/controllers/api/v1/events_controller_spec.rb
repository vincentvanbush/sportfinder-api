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

      context 'contenders' do
        context 'in football' do
          let(:discipline) { FactoryGirl.create :discipline, title: 'football' }
          let(:attrs) do
            team1 = { title: 'Arsenal', squad_members: ['Mertesacker', 'Ramsey', 'Wilshire']}
            team2 = { title: 'Liverpool', squad_members: ['Coutinho', 'Sturridge', 'Henderson']}
            FactoryGirl.attributes_for(:event)
                                 .merge({ contenders: [team1, team2] })
          end
          before do
            post :create, { discipline_id: discipline.slug,
                          user_id: user.id,
                          event: attrs }
            @event = Event.first
          end

          

          let(:event_attributes) do
            { contenders: [{ title: 'Arsenal', 
                            squad_members: ['Szczesny', 'Sanchez', 'Giroud'],
                            stats: { 
                              goals: [{ scorer: 'Sanchez', minute: 55, penalty: false }],
                              substitutions: [{ player_off: 'Giroud', player_on: 'Wallcot', minute: 69 }]}}, 
                           { title: 'Liverpool', 
                            squad_members: ['Mignolet', 'Gerrard', 'Sterling'], 
                            score: 2 }]}
          end

          before do
            patch :update, { discipline_id: discipline.slug,
                            user_id: user.id,
                            id: @event.id,
                            event: event_attributes }
          end

          it 'nests updated info about contenders' do
            expect(json_response[:event]).to have_key(:contenders)
            expect(json_response[:event][:contenders].length).to eql(2)
            expect(json_response[:event][:contenders][0]).to have_key(:title)
            expect(json_response[:event][:contenders][0]).to have_key(:stats)
            expect(json_response[:event][:contenders][0]).not_to have_key(:partial_scores)
            expect(json_response[:event][:contenders][0]).not_to have_key(:total_time)
          end

          it 'nests updated info about squad_members' do
            expect(json_response[:event][:contenders][0]).to have_key(:squad_members)
            expect(json_response[:event][:contenders][0][:title]).to eql('Arsenal')
            expect(json_response[:event][:contenders][0][:squad_members]).to include('Szczesny')
            expect(json_response[:event][:contenders][1][:squad_members]).not_to include('Henderson')
          end

          it 'nests updated info about score' do
            expect(json_response[:event][:contenders][0]).to have_key(:score)
            expect(json_response[:event][:contenders][1][:score]).to eql 2
          end

          it 'nests updated info about stats' do
            expect(json_response[:event][:contenders][0][:stats][:goals][0][:scorer]).to eql 'Sanchez'
            expect(json_response[:event][:contenders][0][:stats][:goals][0][:minute]).to eql '55'
            expect(json_response[:event][:contenders][0][:stats][:goals][0][:penalty]).to eql false

            expect(json_response[:event][:contenders][0][:stats][:substitutions][0][:player_off]).to eql 'Giroud'
            expect(json_response[:event][:contenders][0][:stats][:substitutions][0][:player_on]).to eql 'Wallcot'
            expect(json_response[:event][:contenders][0][:stats][:substitutions][0][:minute]).to eql '69'
          end

          it { should respond_with 201 }
        end

        context 'volleyball' do
          let(:discipline) { FactoryGirl.create :discipline, title: 'volleyball' }
          let(:event) { FactoryGirl.create :event, discipline: discipline, user: user }

          let(:event_attributes) do
            { contenders: [{ title: 'AZS Częstochowa', 
                            squad_members: ['bla', 'qwe'],
                            score: 0,
                            partial_scores: { set_1: 21 } },
                           { title: 'Effector Kielce', 
                            squad_members: ['asd', 'zxc'],
                            score: 1,
                            partial_scores: { set_1: 25 }}]}
          end

          before do
            patch :update, { discipline_id: discipline.slug,
                            user_id: user.id,
                            id: event.id,
                            event: event_attributes }
          end

          it 'nests updated info about contenders' do
            expect(json_response[:event]).to have_key(:contenders)
            expect(json_response[:event][:contenders].length).to eql(2)
            expect(json_response[:event][:contenders][0]).to have_key(:title)
            expect(json_response[:event][:contenders][0]).not_to have_key(:stats)
            expect(json_response[:event][:contenders][0]).to have_key(:partial_scores)
            expect(json_response[:event][:contenders][0]).not_to have_key(:total_time)
          end

          it 'nests updated info about squad_members' do
            expect(json_response[:event][:contenders][0]).to have_key(:squad_members)
            expect(json_response[:event][:contenders][0][:title]).to eql('AZS Częstochowa')
            expect(json_response[:event][:contenders][1][:squad_members]).to include('asd')
          end

          it 'nests updated info about score' do
            expect(json_response[:event][:contenders][0]).to have_key(:score)
            expect(json_response[:event][:contenders][1][:score]).to eql 1
          end

          it 'nests updated info about partial scores' do
            expect(json_response[:event][:contenders][0][:partial_scores][:set_1]).to eql '21'
            expect(json_response[:event][:contenders][1][:partial_scores][:set_1]).to eql '25'
          end
        end

        context 'basketball' do
          let(:discipline) { FactoryGirl.create :discipline, title: 'basketball' }
          let(:event) { FactoryGirl.create :event, discipline: discipline, user: user }

          let(:event_attributes) do
            { contenders: [{ title: 'Chicago Bulls', 
                            squad_members: ['bla', 'qwe'],
                            score: 101,
                            partial_scores: { quarter_1: 25, quarter_2: 26, quarter_3: 25, quarter_4: 25 } },
                           { title: 'Miami Heat', 
                            squad_members: ['asd', 'zxc'],
                            score: 98,
                            partial_scores: { quarter_1: 25, quarter_2: 24, quarter_3: 24, quarter_4: 25 }}]}
          end

          before do
            patch :update, { discipline_id: discipline.slug,
                            user_id: user.id,
                            id: event.id,
                            event: event_attributes }
          end

          it 'nests updated info about contenders' do
            expect(json_response[:event]).to have_key(:contenders)
            expect(json_response[:event][:contenders].length).to eql(2)
            expect(json_response[:event][:contenders][0]).to have_key(:title)
            expect(json_response[:event][:contenders][0]).not_to have_key(:stats)
            expect(json_response[:event][:contenders][0]).to have_key(:partial_scores)
            expect(json_response[:event][:contenders][0]).not_to have_key(:total_time)
          end

          it 'nests updated info about squad_members' do
            expect(json_response[:event][:contenders][0]).to have_key(:squad_members)
            expect(json_response[:event][:contenders][1][:title]).to eql('Miami Heat')
            expect(json_response[:event][:contenders][1][:squad_members]).to include('asd')
          end

          it 'nests updated info about socre' do
            expect(json_response[:event][:contenders][0]).to have_key(:score)
            expect(json_response[:event][:contenders][1][:score]).to eql 98
          end

          it 'nests updated info about partial scores' do
            expect(json_response[:event][:contenders][0][:partial_scores][:quarter_1]).to eql '25'
            expect(json_response[:event][:contenders][0][:partial_scores][:quarter_2]).to eql '26'
            expect(json_response[:event][:contenders][1][:partial_scores][:quarter_3]).to eql '24'
            expect(json_response[:event][:contenders][1][:partial_scores][:quarter_4]).to eql '25'
          end
        end

        context 'tennis' do
          let(:discipline) { FactoryGirl.create :discipline, title: 'tennis' }
          let(:event) { FactoryGirl.create :event, discipline: discipline, user: user }

          let(:event_attributes) do
            { contenders: [{ title: 'Novak Djokovic', 
                            score: 2,
                            partial_scores: { set_1: { gems_won: 6, tiebreak: false },
                                              set_2: { gems_won: 6, tiebreak: true, tiebreak_points: 4 },
                                              set_3: { gems_won: 6, tiebreak: false } } },
                           { title: 'Rafael Nadal', 
                            score: 1,
                            partial_scores: { set_1: { gems_won: 4, tiebreak: false },
                                              set_2: { gems_won: 7, tiebreak: true, tiebreak_points: 7 },
                                              set_3: { gems_won: 2, tiebreak: false } } }]}
          end

          before do
            patch :update, { discipline_id: discipline.slug,
                            user_id: user.id,
                            id: event.id,
                            event: event_attributes }
          end

          it 'nests updated info about contenders' do
            expect(json_response[:event]).to have_key(:contenders)
            expect(json_response[:event][:contenders].length).to eql(2)
            expect(json_response[:event][:contenders][0]).to have_key(:title)
            expect(json_response[:event][:contenders][0]).not_to have_key(:stats)
            expect(json_response[:event][:contenders][0]).to have_key(:partial_scores)
            expect(json_response[:event][:contenders][0]).not_to have_key(:total_time)
          end

          it 'nests updated info about socre' do
            expect(json_response[:event][:contenders][0]).to have_key(:score)
            expect(json_response[:event][:contenders][1][:score]).to eql 1
          end

          it 'nests updated info about partial scores' do
            expect(json_response[:event][:contenders][0][:partial_scores][:set_2][:gems_won]).to eql '6'
            expect(json_response[:event][:contenders][0][:partial_scores][:set_2][:tiebreak_points]).to eql '4'
            expect(json_response[:event][:contenders][1][:partial_scores][:set_3][:tiebreak]).to be false
            expect(json_response[:event][:contenders][1][:partial_scores][:set_2][:gems_won]).to eql '7'
          end
        end

        context 'race' do
          let(:discipline) { FactoryGirl.create :discipline, title: 'race' }
          let(:event) { FactoryGirl.create :event, discipline: discipline, user: user }

          let(:event_attributes) do
            { contenders: [{ title: 'Ferrari', 
                            total_time: '15m 9s 395ms',
                            lap_times: ['5m 29s 901ms', '9m 92s 135ms'] },
                           { title: 'McLaren', 
                            total_time: '10m 1s 902ms',
                            lap_times: ['3m 24s 729ms', '9m 32s 810ms'] },
                           { title: 'Lotus',
                            total_time: '15m 12s 890ms',
                            lap_times: ['6m 15s 205ms', '4m 28s 193ms'] },
                           { title: 'Toro Rosso',
                            total_time: '20m 13s 123ms',
                            lap_times: ['3m 13s 914ms', '6m 43s 144ms'] }]}
          end

          before do
            patch :update, { discipline_id: discipline.slug,
                            user_id: user.id,
                            id: event.id,
                            event: event_attributes }
          end

          it 'nests updated info about contenders' do
            expect(json_response[:event]).to have_key(:contenders)
            expect(json_response[:event][:contenders].length).to eql(4)
            expect(json_response[:event][:contenders][0]).to have_key(:title)
            expect(json_response[:event][:contenders][0]).not_to have_key(:stats)
            expect(json_response[:event][:contenders][0]).not_to have_key(:partial_scores)
            expect(json_response[:event][:contenders][0]).to have_key(:total_time)
            expect(json_response[:event][:contenders][0]).to have_key(:lap_times)
          end

          it 'nests updated info about total time' do
            expect(json_response[:event][:contenders][2][:total_time]).to eql '15m 12s 890ms'
          end

          it 'nests updated info about lap_times' do
            expect(json_response[:event][:contenders][0][:lap_times]).to have_exactly(2).items()
            expect(json_response[:event][:contenders][3][:lap_times][1]).to eql '6m 43s 144ms'
          end
        end
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
