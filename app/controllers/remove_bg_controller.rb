# frozen_string_literal: true

class RemoveBgController < ApplicationController
  def index
    @uuid = params[:uuid]
  end

  def new
    @files_data = Uploadcare::FileApi.get_files(ordering: '-datetime_uploaded')
    @files = @files_data[:results]
  end

  def create
    result = Uploadcare::AddonsApi.remove_bg(params[:file], **options_params.compact)
    redirect_to remove_bg_index_path(uuid: result['request_id'])
  end

  def show_status
    @result = params[:result]
  end

  def check_status
    result = Uploadcare::AddonsApi.remove_bg_status(params[:uuid])
    redirect_to show_status_remove_bg_index_path(result: result)
  end

  private

  def options_params
    params.require(:options).permit(:crop, :crop_margin, :scale, :type_level)
  end
end
