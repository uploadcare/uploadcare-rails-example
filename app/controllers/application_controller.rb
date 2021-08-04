# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from Uploadcare::Exception::RequestError, with: :handle_error

  def redirect_to_prev_location
    redirect_to request.referer || files_path
  end

  def handle_error(exception)
    flash[:alert] = exception.message.presence || 'Something went wrong'
    redirect_to_prev_location
  end
end
