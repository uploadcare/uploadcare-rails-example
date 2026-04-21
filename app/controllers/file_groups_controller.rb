# frozen_string_literal: true

class FileGroupsController < ApplicationController
  def index
    obtain_remote_groups
  end

  def new
    @files_data = uploadcare_client.files.list(ordering: "-datetime_uploaded")
    @files = @files_data.resources
  end

  def show
    @file_group = uploadcare_client.groups.find(group_id: file_group_params[:id])
    @files = Array(@file_group.files).map { |file| Uploadcare::File.new(file, uploadcare_client) }
    @date_format = "%B %d, %Y %H:%M"
  end

  def store
    file_group = uploadcare_client.groups.find(group_id: file_group_params[:id])
    uuids = Array(file_group.files).filter_map { |file| file["uuid"] || file[:uuid] }
    uploadcare_client.files.batch_store(uuids: uuids) if uuids.any?
    flash[:success] = "File group has been successfully stored!"
    redirect_back_or_to file_groups_path
  end

  def create
    new_group = uploadcare_client.groups.create(uuids: file_group_params[:files].values)
    flash[:success] = "File group has been successfully created!"
    redirect_to file_group_path(new_group.id)
  end

  def destroy
    uploadcare_client.groups.find(group_id: file_group_params[:id]).delete
    redirect_to file_groups_path
  end

  private

  def file_group_params
    params.permit(:id, files: {})
  end

  def obtain_remote_groups
    @file_groups_data = uploadcare_client.groups.list(ordering: "-datetime_created")
    @file_groups = @file_groups_data.resources
  end
end
