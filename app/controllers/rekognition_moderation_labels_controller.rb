# frozen_string_literal: true

class RekognitionModerationLabelsController < ApplicationController
  def index
    @uuid = params[:uuid]
  end

  def new
    @files_data = Uploadcare::FileApi.get_files(ordering: "-datetime_uploaded")
    @files = @files_data[:results]
  end

  def create
    result = Uploadcare::AddonsApi.rekognition_detect_moderation_labels(params[:file])
    redirect_to rekognition_moderation_labels_path(uuid: result["request_id"])
  end

  def show_status
    @result = params[:result]
  end

  def check_status
    result = Uploadcare::AddonsApi.rekognition_detect_moderation_labels_status(params[:uuid])
    redirect_to show_status_rekognition_moderation_labels_path(result: result)
  end
end
