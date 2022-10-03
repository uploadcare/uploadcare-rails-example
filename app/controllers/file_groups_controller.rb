# frozen_string_literal: true

class FileGroupsController < ApplicationController
  def index
    obtain_remote_files
  end

  def new
    @files_data = Uploadcare::FileApi.get_files(ordering: '-datetime_uploaded')
    @files = @files_data[:results]
  end

  def show
    @file_group = Uploadcare::GroupApi.get_group(file_group_params[:id])
    @date_format = '%B %d, %Y %H:%M'
  end

  def store
    Uploadcare::GroupApi.store_group(file_group_params[:id])
    flash[:success] = 'File group has been successfully stored!'
    redirect_to_prev_location
  end

  def create
    new_group = Uploadcare::GroupApi.create_group(file_group_params[:files].values)
    flash[:success] = 'File group has been successfully created!'
    redirect_to file_group_path(new_group.id)
  end

  def destroy
    Uploadcare::GroupApi.delete_group(file_group_params[:id])
    redirect_to file_groups_path
  end

  private

  def file_group_params
    params.permit(:id, files: {})
  end

  def obtain_remote_files
    @file_groups_data = Uploadcare::GroupApi.get_groups
    @file_groups = @file_groups_data[:results]
  end
end
