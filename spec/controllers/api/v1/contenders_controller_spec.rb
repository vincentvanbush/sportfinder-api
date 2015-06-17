require 'rails_helper'

RSpec.describe Api::V1::ContendersController, type: :controller do
	describe 'GET #show' do
		let(:user) { FactoryGirl.create :user }
		before(:each) do
			api_authorization_header user.auth_token
		end

		let(:discipline) { FactoryGirl.create :discipline, title: 'football' }
		let(:attrs) do
		          team1 = { title: 'Arsenal', squad_members: ['Mertesacker', 'Ramsey', 'Wilshire']}
		          team2 = { title: 'Liverpool', squad_members: ['Coutinho', 'Sturridge', 'Henderson']}
		          FactoryGirl.attributes_for(:event)
		                               .merge({ contenders: [team1, team2] })
		                               .merge(discipline_id: discipline.id)
		                               .merge(user_id: user.id)
		end
    let(:event) { Event.create(attrs) }

    let(:contender_attributes) do
			    	{ title: 'Chelsea', score: 3, squad_members: ['Hazard', 'Drogba', 'Mikel'],
			    	stats: { goals: [{ scorer: 'Silva', minute: 34, penalty: false, own_goal: false }],
		    						substitutions: [{ player_off: 'Hart', player_on: 'Dzeko', minute: 5 }]} }
    end

    before do
    	patch :update, { discipline_id: discipline.slug,
    										user_id: user.id,
    										event_id: event.id, 
    										id: event.contenders[1].id,
    										contender: contender_attributes }
		end

		context 'for a contender that exists' do
			before do
				get :show, discipline_id: discipline.id, event_id: event.id, id: event.contenders[1].id
			end

			it 'returns info about contender' do
				expect(json_response[:contender][:title]).to eql 'Chelsea'
				expect(json_response[:contender][:score]).to eql 3
				expect(json_response[:contender][:squad_members]).to have_exactly(3).items()
				expect(json_response[:contender]).to have_key(:stats)
				expect(json_response[:contender][:stats]).to have_key(:goals)
				expect(json_response[:contender][:stats]).to have_key(:substitutions)
				expect(json_response[:contender][:stats][:goals][0]).to have_key(:penalty)
				expect(json_response[:contender][:stats][:goals][0][:penalty]).to eql false
				expect(json_response[:contender][:stats][:substitutions][0]).to have_key(:player_on)
				expect(json_response[:contender][:stats][:substitutions][0][:player_on]).to eql 'Dzeko'
			end

			it { should respond_with 200 }
		end

		context 'for a nonexistent discipline' do
			before do
				get :show, discipline_id: 'igas', event_id: event.id, id: event.contenders[1].id
			end

			it { should respond_with 404 }
		end

		context 'for a nonexistent event' do
			before do
				get :show, discipline_id: discipline.id, event_id: 'soga', id: event.contenders[1].id
			end

			it { should respond_with 404 }
		end

		context 'for a nonexistent contender' do
			before do
				get :show, discipline_id: discipline.id, event_id: event.id, id: 'sdkajg'
			end

			it { should respond_with 404 }
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
		  	let(:attrs) do
		          team1 = { title: 'Arsenal', squad_members: ['Mertesacker', 'Ramsey', 'Wilshire']}
		          team2 = { title: 'Liverpool', squad_members: ['Coutinho', 'Sturridge', 'Henderson']}
		          FactoryGirl.attributes_for(:event)
		                               .merge({ contenders: [team1, team2] })
		                               .merge(discipline_id: discipline.id)
		                               .merge(user_id: user.id)
		    end
		    let(:event) { Event.create(attrs) }

		    context 'in first contender' do
			    let(:first_contender_attributes) do
			    	{ title: 'Chelsea', score: 3, squad_members: ['Hazard', 'Drogba', 'Mikel'] }
			    end

			    before do
			    	patch :update, { discipline_id: discipline.slug,
			    										user_id: user.id,
			    										event_id: event.id, 
			    										id: event.contenders[0].id,
			    										contender: first_contender_attributes }
					end

			    it 'return updated info' do
			    	expect(json_response[:contender][:score]).to eql 3
			    	expect(json_response[:contender][:title]).to eql 'Chelsea'
			    	expect(json_response[:contender][:squad_members]).to have_exactly(3).items()
			    	expect(json_response[:contender][:squad_members][1]).to eql 'Drogba'
			    end

			    it { should respond_with 201 }
								    
			  end

			  context 'in second contender' do
			    let(:second_contender_attributes) do
			    	{ title: 'City', score: 2, squad_members: ['Silva', 'Nazri', 'Hart'] }
			    end
			  	
			  	before do
			    	patch :update, { discipline_id: discipline.slug,
			    										user_id: user.id,
			    										event_id: event.id, 
			    										id: event.contenders[1].id,
			    										contender: second_contender_attributes }	
			    end								
		    	
		    	it 'return updated info' do
			    	expect(json_response[:contender][:score]).to eql 2
			    	expect(json_response[:contender][:title]).to eql 'City'
			    	expect(json_response[:contender][:squad_members]).to have_exactly(3).items()
			    	expect(json_response[:contender][:squad_members][1]).to eql 'Nazri'
			    end

		    	it { should respond_with 201 }
			  end
		  end

		  context 'football stats' do
		  	let(:discipline) { FactoryGirl.create :discipline, title: 'football' }
		  	let(:attrs) do
		          team1 = { title: 'Arsenal', squad_members: ['Mertesacker', 'Ramsey', 'Wilshire']}
		          team2 = { title: 'Liverpool', squad_members: ['Coutinho', 'Sturridge', 'Henderson']}
		          FactoryGirl.attributes_for(:event)
		                               .merge({ contenders: [team1, team2] })
		                               .merge(discipline_id: discipline.id)
		                               .merge(user_id: user.id)
		    end
		    let(:event) { Event.create(attrs) }

		    let(:contender_attributes) do
		    	{ title: 'City', score: 1, squad_members: ['Silva', 'Nazri', 'Hart'],
		    		stats: { goals: [{ scorer: 'Silva', minute: 34, penalty: false, own_goal: false }],
		    						substitutions: [{ player_off: 'Hart', player_on: 'Dzeko', minute: 5 }]}}
		    end

		    before do
		    	patch :update, { discipline_id: discipline.slug,
		    									user_id: user.id,
		    									event_id: event.id,
		    									id: event.contenders[0].id,
		    									contender: contender_attributes }
		    end

		    context 'after adding goal and substitution' do

		    	it 'returns one goal and one substitution' do
		    		expect(json_response[:contender][:score]).to eql 1
			    	expect(json_response[:contender][:title]).to eql 'City'
			    	expect(json_response[:contender][:squad_members]).to have_exactly(3).items()
			    	expect(json_response[:contender][:squad_members][1]).to eql 'Nazri'

			    	expect(json_response[:contender]).to have_key(:stats)
			    	expect(json_response[:contender][:stats]).to have_key(:goals)
			    	expect(json_response[:contender][:stats]).to have_key(:substitutions)
			    	expect(json_response[:contender][:stats][:goals]).to have_exactly(1).item()
			    	expect(json_response[:contender][:stats][:substitutions]).to have_exactly(1).item()
			    	expect(json_response[:contender][:stats][:goals][0][:scorer]).to eql 'Silva'
			    	expect(json_response[:contender][:stats][:substitutions][0][:minute]).to eql '5'
		    	end

		    	it { should respond_with 201 }

		    end

		    context 'after adding some stats twice' do
		    	let(:new_contender_attributes) do
			    	{ title: 'City', score: 2, squad_members: ['Kompany', 'Sagna', 'Aguero'],
			    		stats: { goals: [{ scorer: 'Aguero', minute: 54, penalty: true, own_goal: false }],
			    						substitutions: [{ player_off: 'Silva', player_on: 'Bony', minute: 10 }]}}
		    	end

			    before do
			    	patch :update, { discipline_id: discipline.slug,
			    									user_id: user.id,
			    									event_id: event.id,
			    									id: event.contenders[0].id,
			    									contender: new_contender_attributes }
			    end

			    it 'returns two goals and two substitution' do
		    		expect(json_response[:contender][:score]).to eql 2
			    	expect(json_response[:contender][:title]).to eql 'City'
			    	expect(json_response[:contender][:squad_members]).to have_exactly(3).items()
			    	expect(json_response[:contender][:squad_members][1]).to eql 'Sagna'

			    	expect(json_response[:contender]).to have_key(:stats)
			    	expect(json_response[:contender][:stats]).to have_key(:goals)
			    	expect(json_response[:contender][:stats]).to have_key(:substitutions)
			    	expect(json_response[:contender][:stats][:goals]).to have_exactly(2).item()
			    	expect(json_response[:contender][:stats][:substitutions]).to have_exactly(2).item()
			    	expect(json_response[:contender][:stats][:goals][1][:scorer]).to eql 'Aguero'
			    	expect(json_response[:contender][:stats][:goals][1][:penalty]).to eql true
			    	expect(json_response[:contender][:stats][:substitutions][1][:minute]).to eql '10'
		    	end

		    	it { should respond_with 201 }
		    end

		    context 'after adding second goal without substitution key' do
		    	let(:new_contender_attributes) do
			    	{ title: 'City', score: 2, squad_members: ['Kompany', 'Sagna', 'Aguero'],
			    		stats: { goals: [{ scorer: 'Aguero', minute: 54, penalty: true, own_goal: false }]}}
		    	end

			    before do
			    	patch :update, { discipline_id: discipline.slug,
			    									user_id: user.id,
			    									event_id: event.id,
			    									id: event.contenders[0].id,
			    									contender: new_contender_attributes }
			    end

			    it 'returns two goals and one substitution' do
		    		expect(json_response[:contender][:score]).to eql 2
			    	expect(json_response[:contender][:title]).to eql 'City'
			    	expect(json_response[:contender][:squad_members]).to have_exactly(3).items()
			    	expect(json_response[:contender][:squad_members][1]).to eql 'Sagna'

			    	expect(json_response[:contender]).to have_key(:stats)
			    	expect(json_response[:contender][:stats]).to have_key(:goals)
			    	expect(json_response[:contender][:stats]).to have_key(:substitutions)
			    	expect(json_response[:contender][:stats][:goals]).to have_exactly(2).item()
			    	expect(json_response[:contender][:stats][:substitutions]).to have_exactly(1).item()
			    	expect(json_response[:contender][:stats][:goals][1][:scorer]).to eql 'Aguero'
			    	expect(json_response[:contender][:stats][:goals][1][:penalty]).to eql true
			    	expect(json_response[:contender][:stats][:substitutions][0][:minute]).to eql '5'
		    	end

		    	it { should respond_with 201 }
		  	end
		  end

		  context 'volleyball partial scores' do
		  	let(:discipline) { FactoryGirl.create :discipline, title: 'volleyball' }
		  	let(:attrs) do
		          team1 = { title: 'Warszawa', squad_members: ['qwe', 'asd', 'zxc']}
		          team2 = { title: 'Poznan', squad_members: ['wer', 'sdf', 'xcv']}
		          FactoryGirl.attributes_for(:event)
		                               .merge({ contenders: [team1, team2] })
		                               .merge(discipline_id: discipline.id)
		                               .merge(user_id: user.id)
		    end
		    let(:event) { Event.create(attrs) }

		    let(:contender_attributes) do
		    	{ title: 'Bydgoszcz', score: 1, squad_members: ['ert', 'dfg', 'cvb'],
		    		partial_scores: [21] }
		    end

		    before do
		    	patch :update, { discipline_id: discipline.slug,
		    									user_id: user.id,
		    									event_id: event.id,
		    									id: event.contenders[0].id,
		    									contender: contender_attributes }
		    end

		    context 'after adding first set points scored' do
		    	it 'return updated value about first set' do
		    		expect(json_response[:contender][:score]).to eql 1
			    	expect(json_response[:contender][:title]).to eql 'Bydgoszcz'
			    	expect(json_response[:contender][:squad_members]).to have_exactly(3).items()
			    	expect(json_response[:contender][:squad_members][1]).to eql 'dfg'

			    	expect(json_response[:contender][:partial_scores]).to have_exactly(1).item()
			    	expect(json_response[:contender][:partial_scores][0]).to eql '21'
		    	end

		    	it { should respond_with 201 }
		    end

		    context 'after adding two sets points scored' do
		    	let(:new_contender_attributes) do
			    	{	partial_scores: [25] }
			    end

			    before do
			    	patch :update, { discipline_id: discipline.slug,
			    									user_id: user.id,
			    									event_id: event.id,
			    									id: event.contenders[0].id,
			    									contender: new_contender_attributes }
			    end

			    it 'returns updated info abaut points in two first sets' do
			  		expect(json_response[:contender][:score]).to eql 1
			    	expect(json_response[:contender][:title]).to eql 'Bydgoszcz'
			    	expect(json_response[:contender][:squad_members]).to have_exactly(3).items()
			    	expect(json_response[:contender][:squad_members][1]).to eql 'dfg'

			    	expect(json_response[:contender][:partial_scores]).to have_exactly(2).items()
			    	expect(json_response[:contender][:partial_scores][0]).to eql '21'
			    	expect(json_response[:contender][:partial_scores][1]).to eql '25'
			  	end

			  	it { should respond_with 201 }
		    end
		  end

		  context 'tennis partial scores' do
		  	let(:discipline) { FactoryGirl.create :discipline, title: 'tennis' }
		  	let(:attrs) do
		          team1 = { title: 'Nadal' }
		          team2 = { title: 'Federrer' }
		          FactoryGirl.attributes_for(:event)
		                               .merge({ contenders: [team1, team2] })
		                               .merge(discipline_id: discipline.id)
		                               .merge(user_id: user.id)
		    end
		    let(:event) { Event.create(attrs) }

		    let(:contender_attributes) do
		    	{ title: 'Djokovic', score: 1,
		    		tennis_scores: { set_1: { gems_won: 4,
		    															tiebreak: false },
		    											set_2: { gems_won: 7,
		    															tiebreak: true,
		    															tiebreak_points: 7 }}}
		    end

		    before do
		    	patch :update, { discipline_id: discipline.slug,
		    									user_id: user.id,
		    									event_id: event.id,
		    									id: event.contenders[0].id,
		    									contender: contender_attributes }
		    end

		    context 'after adding results of two sets' do
		    	it 'returns updated into about sets' do
			    	expect(json_response[:contender][:score]).to eql 1
			    	expect(json_response[:contender][:title]).to eql 'Djokovic'

			    	expect(json_response[:contender][:tennis_scores]).to have_key(:set_1)
			    	expect(json_response[:contender][:tennis_scores]).to have_key(:set_2)
			    	expect(json_response[:contender][:tennis_scores]).not_to have_key(:set_3)
			    	expect(json_response[:contender][:tennis_scores][:set_1][:gems_won]).to eql '4'
			    	expect(json_response[:contender][:tennis_scores][:set_2][:tiebreak]).to eql true
			    end
		    end

		    context 'after adding results of two sets and then modifing one' do
		    	let(:new_contender_attributes) do
			    	{ score: 2,
			    		tennis_scores: { set_1: { gems_won: 6,
			    															tiebreak: false },
			    											set_2: { gems_won: 7,
			    															tiebreak: true,
			    															tiebreak_points: 7 }}}
		    	end

		    	before do
			    	patch :update, { discipline_id: discipline.slug,
			    									user_id: user.id,
			    									event_id: event.id,
			    									id: event.contenders[0].id,
			    									contender: new_contender_attributes }
			    end

			    it 'return updated info about sets' do
			    	expect(json_response[:contender][:score]).to eql 2
			    	expect(json_response[:contender][:title]).to eql 'Djokovic'

			    	expect(json_response[:contender][:tennis_scores]).to have_key(:set_1)
			    	expect(json_response[:contender][:tennis_scores]).to have_key(:set_2)
			    	expect(json_response[:contender][:tennis_scores]).not_to have_key(:set_3)
			    	expect(json_response[:contender][:tennis_scores][:set_1][:gems_won]).to eql '6'
			    	expect(json_response[:contender][:tennis_scores][:set_2][:tiebreak]).to eql true
			    end
		    end

		    context 'after adding third set results' do
		    	let(:new_contender_attributes) do
			    	{ score: 2,
			    		tennis_scores: { set_1: { gems_won: 6,
			    															tiebreak: false },
			    											set_3: { gems_won: 2,
			    															tiebreak: false }}}
		    	end

		    	before do
			    	patch :update, { discipline_id: discipline.slug,
			    									user_id: user.id,
			    									event_id: event.id,
			    									id: event.contenders[0].id,
			    									contender: new_contender_attributes }
			    end

			    it 'returns updated info about sets' do
			    	expect(json_response[:contender][:score]).to eql 2
			    	expect(json_response[:contender][:title]).to eql 'Djokovic'

			    	expect(json_response[:contender][:tennis_scores]).to have_key(:set_1)
			    	expect(json_response[:contender][:tennis_scores]).to have_key(:set_2)
			    	expect(json_response[:contender][:tennis_scores]).to have_key(:set_3)
			    	expect(json_response[:contender][:tennis_scores]).not_to have_key(:set_4)
			    	expect(json_response[:contender][:tennis_scores][:set_1][:gems_won]).to eql '6'
			    	expect(json_response[:contender][:tennis_scores][:set_2][:tiebreak]).to eql true
			    	expect(json_response[:contender][:tennis_scores][:set_3][:gems_won]).to eql '2'
			    end
		    end
		  end

    end

    context 'when is not updated' do
    	let(:discipline) { FactoryGirl.create :discipline, title: 'football' }
      let(:event) { FactoryGirl.create :event, discipline: discipline, user: user }
      let(:contender) { FactoryGirl.create :contender, event: event}

      context 'because of nonexistent' do
        context 'discipline' do
          before do
            patch :update, {  discipline_id: 'balbalbabl', 
                              user_id: user.id,
                              event_id: contender.event.slug,
                              id: contender.id }
          end

          it { should respond_with 404 }
        end

        context 'event' do
          before do
            patch :update, {  discipline_id: contender.event.discipline.slug,
                              user_id: user.id,
                              event_id: 'ksadg',
                              id: contender.id }
          end

          it { should respond_with 404 }
        end

        context 'contender' do
          before do
            patch :update, {  discipline_id: contender.event.discipline.slug,
                              user_id: user.id,
                              event_id: contender.event.slug,
                              id: 'sadgklj' }
          end

          it { should respond_with 404 }
        end
      end
    end
	end
end