# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from Uploadcare::Exception::RequestError, with: :handle_error

  def redirect_to_prev_location(message = nil)
    flash[:alert] = message if message.present?
    redirect_to(request.referer || files_path)
  end

  def handle_error(exception)
    redirect_to_prev_location(exception.message.presence || "Something went wrong")
  end
end
