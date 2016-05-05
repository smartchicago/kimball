class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  after_action :flash_to_headers

  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Message'] = flash_message if flash_message
    response.headers['X-Message-Type'] = flash_type.to_s if flash_type
    flash.discard # don't want the flash to appear when you reload page
  end

  private

    def flash_message
      [:error, :warning, :notice].each do |type|
        return flash[type] unless flash[type].blank?
      end
      nil
    end

    def flash_type
      [:error, :warning, :notice].each do |type|
        return type unless flash[type].blank?
      end
      nil
    end

end
