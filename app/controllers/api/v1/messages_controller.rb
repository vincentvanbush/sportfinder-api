class Api::V1::MessagesController < ApplicationController
  respond_to :json

  def index
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    event = discipline.events.find(params[:event_id])
    not_found && return unless event.present?

    messages = event.messages
    messages = messages.after(params[:after]) if params[:after]
    respond_with messages
  end

  def create
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    event = discipline.events.find(params[:event_id])
    not_found && return unless event.present?

    message = event.messages.new(message_params)
    if message.save
      render json: message,
             status: 201,
             location: api_discipline_event_message_url(discipline, event, message)
    else
      render json: { errors: message.errors }, status: 422
    end
  end

  def update
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    event = discipline.events.find(params[:event_id])
    not_found && return unless event.present?
    message = event.messages.find(params[:id])
    not_found && return unless message.present?

    if message.update(message_params)
      render json: message,
             status: 200,
             location: api_discipline_event_message_url(discipline, event, message)
    else
      render json: { errors: message.errors }, status: 422
    end
  end

  def destroy
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    event = discipline.events.find(params[:event_id])
    not_found && return unless event.present?
    message = event.messages.find(params[:id])
    not_found && return unless message.present?

    message.destroy
    head 204
  end

  private

    def message_params
      params.require(:message).permit(:content, :attachment_url)
    end
end
