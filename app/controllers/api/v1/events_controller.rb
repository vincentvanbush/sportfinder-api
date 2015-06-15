class Api::V1::EventsController < ApplicationController
  before_action :authenticate_with_token!, only: [:create]
  respond_to :json

  def show
    discipline = Discipline.find(params[:discipline_id])
    unless discipline.present?
      not_found
    else
      event = discipline.events.find(params[:id])
      respond_with event if event.present?
      not_found if event.nil?
    end
  end

  def index
    discipline = Discipline.or({slugs: params[:discipline_id]},
                               {id: params[:discipline_id]}).first
    not_found && return if discipline.nil?
    events = discipline.events.all
    events = events.finished(params[:finished]) if params.has_key?(:finished)
    events = events.page(params[:page]).per(params[:per_page])
    render json: events, meta: { pagination:
                                   { per_page: params[:per_page],
                                     total_pages: events.total_pages,
                                     total_objects: events.total_count } }
  end

  def create
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    # user = User.find(params[:user_id]) # TODO bind this with current_user!!!
    not_authorized && return unless current_user

    event = discipline.events.new(event_params)
    contenders_params = event_params[:contenders]
    event.user = current_user

    if event.save
      render json: event, status: 201, location: api_discipline_event_url(discipline, event)
    else
      render json: { errors: event.errors }, status: 422
    end

  end

  def update
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    event = Event.find(params[:id])
    not_found && return unless event.present?

    # byebug

    event_par = event_params
    event_par[:finished?] = event_par.delete :finished if event_par.has_key?(:finished)

    event.update(event_par)
    if event.save
      render json: event, status: 201, location: api_discipline_event_url(discipline, event)
    else
      render json: { errors: event.errors }, status: 422
    end
  end

  private
    def contender_params_array(discipline_id)
      contender_params = [:title]
      if params[:discipline_id].present?
        discipline = Discipline.find(params[:discipline_id])
        title = discipline.title if discipline.present?
        contender_params << { squad_members: [] } if ['football', 'volleyball', 'basketball'].include?(title)
        contender_params << :score if ['football', 'basketball', 'volleyball', 'tennis'].include?(title)
        contender_params << { partial_scores: [ :set_1, :set_2, :set_3, :set_4, :set_5 ] } if ['volleyball'].include?(title)
        contender_params << { partial_scores: [ :quarter_1, :quarter_2, :quarter_3, :quarter_4 ] } if ['basketball'].include?(title)

        tennis_set = [:gems_won, :tiebreak, :tiebreak_points]
        contender_params << { partial_scores: { set_1: tennis_set , set_2: tennis_set, set_3: tennis_set, set_4: tennis_set, set_5: tennis_set }} if ['tennis'].include?(title)
        contender_params << :total_time if ['race'].include?(title)
        contender_params << { lap_times: [] } if ['race'].include?(title)
        contender_params << { stats: {  goals: [ :scorer, :minute, :penalty, :own_goal ],
                                        substitutions: [ :player_off, :player_on, :minute ] } } if ['football'].include?(title)
      end
      return contender_params
    end

    def event_params
      contender_params = contender_params_array(params[:discipline_id])
      params.require(:event).permit(:discipline_id,
                                    :user_id,
                                    :title,
                                    :description,
                                    :venue,
                                    :start_date,
                                    :finished,
                                    { contenders: contender_params })
    end
end
