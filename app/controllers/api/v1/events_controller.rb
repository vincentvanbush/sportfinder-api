class Api::V1::EventsController < ApplicationController
  respond_to :json

  def show
    discipline = Discipline.find(params[:discipline_id])
    unless discipline.present?
      not_found
    else
      event = discipline.events.find(params[:id])
      if event.present?
        respond_with event
      else
        not_found
      end
    end
  end
end
