class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :janky_authentication

  protected

  def janky_authentication
    unless Rails.env == "test" || Rails.env == "development"
      authenticate_or_request_with_http_basic do |username, password|
        username == "logan" && password == "smartchicago!"
      end
    else
      true
    end
  end

end
