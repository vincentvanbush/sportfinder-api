class Api::V1::ContendersController < ApplicationController
  before_action :authenticate_with_token!, only: [:update]
  respond_to :json

  def show
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    event = Event.find(params[:event_id])
    not_found && return unless event.present?
    contender = event.contenders.find(params[:id])
    not_found && return unless contender.present?

    respond_with contender
  end


  def update
  	discipline = Discipline.find(params[:discipline_id])
  	not_found && return unless discipline.present?
  	event = Event.find(params[:event_id])
  	not_found && return unless event.present?
  	contender = event.contenders.find(params[:id])
  	not_found && return unless contender.present?

  	contender_par = merge_stats(contender)
  	if contender.update(contender_par)
  		render json: contender, status: 201, location: api_discipline_event_contender_url(discipline, event, contender)
  	else
  		render json: { errors: contender.errors }, status: 422
  	end

  end


  private
	  def search_hash(h, search)
			return h[search] if h.fetch(search, false)

		  h.keys.each do |k|
		    answer = search_hash(h[k], search) if h[k].is_a? Hash
		    return answer if answer
		  end

		  false
		end

    def contender_params
      params.require(:contender).permit(:discipline_id,
                                    :user_id,
                                    :event_id,
                                    :title,
                                    { squad_members: [] },
                                    :score,
                                    { partial_scores: [] },
                                    { lap_time: [] },
                                    { tennis_scores: { set_1: [ :gems_won, :tiebreak, :tiebreak_points ],
                                    					set_2: [ :gems_won, :tiebreak, :tiebreak_points ],
                                    					set_3: [ :gems_won, :tiebreak, :tiebreak_points ],
                                    					set_4: [ :gems_won, :tiebreak, :tiebreak_points ],
                                    					set_5: [ :gems_won, :tiebreak, :tiebreak_points ] }},
                                    { stats: { goals: [ :scorer, :minute, :penalty, :own_goal ],
                                				substitutions: [ :player_off, :player_on, :minute ]}})
    end

    def merge_stats(contender)
    	contender_par = contender_params

			contender_par[:stats] ||= {}
			contender[:stats] ||= {}
	  	new_goals = contender_par[:stats][:goals] || []
	  	old_goals = contender[:stats][:goals] || []
	  	contender_par[:stats][:goals] = old_goals + new_goals
		  
		  new_subs = contender_par[:stats][:substitutions] || []
		  old_subs = contender[:stats][:substitutions] || []
		  contender_par[:stats][:substitutions] = old_subs + new_subs

		  contender_par[:partial_scores] ||= []
		  contender[:partial_scores] ||= []
		  new_partial_scores = contender_par[:partial_scores] || []
		  old_parital_scores = contender[:partial_scores] || []
		  contender_par[:partial_scores] = old_parital_scores + new_partial_scores

		  contender_par[:lap_times] ||= []
		  contender[:lap_times] ||= []
		  new_lap_times = contender_par[:lap_times] || []
		  old_lap_times = contender[:lap_times] || []
		  contender_par[:lap_times] = old_lap_times + new_lap_times

      if contender_par.has_key?(:tennis_scores) 
        contender[:tennis_scores] ||= {}
        5.times do |i|
          key = "set_" + (i+1).to_s
          if contender_par[:tennis_scores].has_key?(key)
            contender[:tennis_scores][key] ||= {}
            contender[:tennis_scores][key].merge!(contender_par[:tennis_scores][key])
            contender_par[:tennis_scores][key].merge!(contender[:tennis_scores][key])
          else
            if contender[:tennis_scores].has_key?(key)
              contender_par[:tennis_scores][key] ||= {}
              contender[:tennis_scores][key] ||= {}
              contender_par[:tennis_scores][key].merge!(contender[:tennis_scores][key])
            end
          end
        end
      end

		  contender_par
    end
end