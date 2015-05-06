class Api::V1::MessagesController < ApplicationController
  respond_to :json

  def index
    discipline = Discipline.find(params[:discipline_id])
    not_found unless discipline.present?
    event = discipline.events.find(params[:event_id])
    not_found unless event.present?

    messages = event.messages
    messages = messages.after(params[:after]) if params[:after]
    respond_with messages
  end
end
