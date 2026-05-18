# frozen_string_literal: true

class FilesController < ApplicationController
  def index
    obtain_remote_files
  end

  def copy
    file = uploadcare_client.files.copy_to_local(source: file_params[:id])
    flash[:success] = "File '#{file.original_filename}' has been successfully copied!"
    redirect_back_or_to files_path
  end

  def store
    uploadcare_client.files.find(uuid: file_params[:id]).store
    flash[:success] = "File has been successfully stored!"
    redirect_back_or_to files_path
  end

  def show
    @file = uploadcare_client.files.find(uuid: file_params[:id])
  end

  def destroy
    uploadcare_client.files.find(uuid: file_params[:id]).delete
    flash[:success] = "File has been successfully deleted!"
    redirect_back_or_to files_path
  end

  def new_store_file_batch
    obtain_remote_files
  end

  def new_delete_file_batch
    obtain_remote_files
  end

  def store_file_batch
    files = file_params[:files].to_h.symbolize_keys
    keys = files.keys
    values = files.values
    uploadcare_client.files.batch_store(uuids: values)
    flash[:success] = "File(s) #{keys.join(', ')} has been successfully stored!"
    redirect_back_or_to files_path
  end

  def delete_file_batch
    files = file_params[:files].to_h.symbolize_keys
    keys = files.keys
    values = files.values
    uploadcare_client.files.batch_delete(uuids: values)
    flash[:success] = "File(s) #{keys.join(', ')} has been successfully deleted!"
    redirect_back_or_to files_path
  end

  private

  def file_params
    params.permit(:id, files: {})
  end

  def obtain_remote_files
    @files_data = uploadcare_client.files.list(ordering: "-datetime_uploaded")
    @files = @files_data.resources
  end
end
