require 'active_record'

class Api::V1::UsersController < ApplicationController
  respond_to :json

  def show
    user = User.find(params[:id])
    if user.present?
      respond_with user
    else
      not_found
    end
  end
end
