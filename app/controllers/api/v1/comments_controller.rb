class Api::V1::CommentsController < ApplicationController
  before_action :authenticate_with_token!, only: [:create, :destroy]
  respond_to :json

  def create
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    event = discipline.events.find(params[:event_id])
    not_found && return unless event.present?

    comment = event.comments.new(comment_params)
    comment.user = current_user
    if comment.save
      render json: comment,
             status: 201,
             location: api_discipline_event_comment_url(discipline, event, comment)
    else
      render json: { errors: comment.errors }, status: 422
    end
  end

  def destroy
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    event = discipline.events.find(params[:event_id])
    not_found && return unless event.present?
    comment = event.comments.find(params[:id])
    not_found && return unless event.present?

    comment.destroy
    head 204
  end

  def index
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    event = discipline.events.find(params[:event_id])
    not_found && return unless event.present?

    comments = event.comments
    comments = comments.after(params[:after]) if params[:after]
    respond_with comments
  end

  private

    def comment_params
      params.require(:comment).permit(:content)
    end
end
