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
end
