# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from Uploadcare::Exception::RequestError, with: :handle_error

  private

  def handle_error(exception)
    flash[:alert] = exception.message.presence || "Something went wrong"
    redirect_back_or_to files_path
  end
end
