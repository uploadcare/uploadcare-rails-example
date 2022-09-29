# frozen_string_literal: true

class VirusScanController < ApplicationController
  def index
    @uuid = params[:uuid]
  end

  def new
    @files_data = Uploadcare::FileApi.get_files(ordering: '-datetime_uploaded')
    @files = @files_data[:results]
  end

  def create
    result = Uploadcare::Addons.uc_clamav_virus_scan(params[:file], purge_infected: params[:purge_infected])
    redirect_to virus_scan_index_path(uuid: result['request_id'])
  end

  def show_status
    @result = params[:result]
  end

  def check_status
    result = Uploadcare::Addons.uc_clamav_virus_scan_status(params[:uuid])
    redirect_to show_status_virus_scan_index_path(result: result)
  end
end
