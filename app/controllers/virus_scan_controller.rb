# frozen_string_literal: true

class VirusScanController < ApplicationController
  def index
    @uuid = params[:uuid]
  end

  def new
    @files_data = uploadcare_client.files.list(ordering: "-datetime_uploaded")
    @files = @files_data.resources
  end

  def create
    result = uploadcare_client.addons.uc_clamav_virus_scan(
      uuid: params[:file],
      params: { purge_infected: uploadcare_bool(params[:purge_infected]) }.compact
    )
    redirect_to virus_scan_index_path(uuid: result.request_id)
  end

  def show_status
    @status = params[:status]
  end

  def check_status
    result = uploadcare_client.addons.uc_clamav_virus_scan_status(request_id: params[:uuid])
    redirect_to show_status_virus_scan_index_path(status: result.status)
  end
end
