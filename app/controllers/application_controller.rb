class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def not_found
    render :json => {:error => "not-found"}.to_json, :status => 404
  end

  def exception
    render :json => {:error => "internal-server-error"}.to_json, :status => 500
  end
end
