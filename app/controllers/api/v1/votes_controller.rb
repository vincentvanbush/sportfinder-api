class Api::V1::VotesController < ApplicationController
  before_action :authenticate_with_token!, only: [:create]

  def create
    discipline = Discipline.find(params[:discipline_id])
    not_found && return unless discipline.present?
    event = discipline.events.find(params[:event_id])
    not_found && return unless event.present?
    user = User.find(params[:user_id])
    not_found && return unless user.present?

    vote = event.votes.new(vote_params)
    vote.user = user
    if vote.save
      render json: vote,
             status: 201
    else
      render json: { errors: vote.errors }, status: 422
    end
  end

  private

    def vote_params
      params.require(:vote).permit(:positive?)
    end
end
