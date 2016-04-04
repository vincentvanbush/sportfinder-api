class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  include Authenticable

  def not_found
    render :json => {:error => "not-found"}.to_json, :status => 404
  end

  def exception
    render :json => {:error => "internal-server-error"}.to_json, :status => 500
  end

  def not_authorized
  	render :json => {:error => "not-authorized"}.to_json, :status => 401
  end

  def default_serializer_options
    {root: false}
  end
end
