# frozen_string_literal: true

class RekognitionLabelsController < ApplicationController
  def index
    @uuid = params[:uuid]
  end

  def new
    @files_data = uploadcare_client.files.list(ordering: "-datetime_uploaded")
    @files = @files_data.resources
  end

  def create
    result = uploadcare_client.addons.aws_rekognition_detect_labels(uuid: params[:file])
    redirect_to rekognition_labels_path(uuid: result.request_id)
  end

  def show_status
    @status = params[:status]
  end

  def check_status
    result = uploadcare_client.addons.aws_rekognition_detect_labels_status(request_id: params[:uuid])
    redirect_to show_status_rekognition_labels_path(status: result.status)
  end
end
