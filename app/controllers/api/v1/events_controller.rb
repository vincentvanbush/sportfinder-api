class Api::V1::EventsController < ApplicationController
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
    discipline = Discipline.find(params[:discipline_id])
    respond_with discipline.events.all if discipline.present?
    not_found if discipline.nil?
  end

  def create
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    user = User.find(params[:user_id])
    not_found && return unless user.present?

    event = discipline.events.new(event_params)
    contenders_params = event_params[:contenders]
    event.user = user

    if event.save
      render json: event, status: 201, location: api_discipline_event_url(discipline, event)
    else
      render json: { errors: event.errors }, status: 422
    end

  end

  private

    def event_params
      params.require(:event).permit(:discipline_id,
                                    :user_id,
                                    :title,
                                    :description,
                                    :venue,
                                    :start_date,
                                    :finished,
                                    { contenders: :title })
    end
end
