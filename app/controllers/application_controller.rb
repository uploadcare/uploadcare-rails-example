# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from Uploadcare::Exception::RequestError, with: :handle_error

  private

  def uploadcare_client
    Uploadcare::Rails.client
  end

  def uploadcare_bool(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end

  def load_group_files(attachment)
    return [] unless attachment

    group = attachment.load
    Array(group.files).map { |file| Uploadcare::File.new(file, Uploadcare.client) }
  end

  def handle_error(exception)
    flash[:alert] = exception.message.presence || "Something went wrong"
    redirect_back_or_to files_path
  end
end
