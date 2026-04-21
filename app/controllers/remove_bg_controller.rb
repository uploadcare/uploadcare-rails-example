# frozen_string_literal: true

class RemoveBgController < ApplicationController
  def index
    @uuid = params[:uuid]
  end

  def new
    @files_data = uploadcare_client.files.list(ordering: "-datetime_uploaded")
    @files = @files_data.resources
  end

  def create
    result = uploadcare_client.addons.remove_bg(uuid: params[:file], params: options_params.compact.to_h)
    redirect_to remove_bg_index_path(uuid: result.request_id)
  end

  def show_status
    @status = params[:status]
  end

  def check_status
    result = uploadcare_client.addons.remove_bg_status(request_id: params[:uuid])
    redirect_to show_status_remove_bg_index_path(status: result.status)
  end

  private

  def options_params
    params.fetch(:options, {}).permit(:crop, :crop_margin, :scale, :type_level)
  end
end
