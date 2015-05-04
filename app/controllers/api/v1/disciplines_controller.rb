class Api::V1::DisciplinesController < ApplicationController
  respond_to :json

  def show
    discipline = Discipline.find(params[:id])
    if discipline.present?
      respond_with discipline
    else
      not_found
    end
  end

  
end
