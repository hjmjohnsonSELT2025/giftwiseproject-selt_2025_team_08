class ErrorsController < ActionController::Base
  include Rails.application.routes.url_helpers
  helper_method :logged_in?
  
  layout "error"

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end

  private

  def logged_in?
    session[:user_id].present?
  end
end
