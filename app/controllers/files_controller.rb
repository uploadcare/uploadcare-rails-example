# frozen_string_literal: true

class FilesController < ApplicationController
  def index
    obtain_remote_files
  end

  def store
    Uploadcare::FileApi.store_file(file_params[:id])
    flash[:success] = 'File has been successfully stored!'
    redirect_to_prev_location
  end

  def show
    @file = Uploadcare::FileApi.get_file(file_params[:id])
  end

  def destroy
    Uploadcare::FileApi.delete_file(file_params[:id])
    flash[:success] = 'File has been successfully deleted!'
    redirect_to_prev_location
  end

  def new_store_file_batch
    obtain_remote_files
  end

  def new_delete_file_batch
    obtain_remote_files
  end

  def store_file_batch
    files = params[:files]
    Uploadcare::FileApi.store_files(files.values)
    flash[:success] = "File(s) #{files.keys.join(', ')} has been successfully stored!"
    redirect_to_prev_location
  end

  def delete_file_batch
    files = params[:files]
    keys, values = files.is_a?(Hash) ? [files.keys, files.values] : [[], files]
    Uploadcare::FileApi.delete_files(values)
    flash[:success] = "File(s) #{keys.join(', ')} has been successfully deleted!"
    redirect_to_prev_location
  end

  private

  def file_params
    params.permit(:id)
  end

  def obtain_remote_files
    @files_data = Uploadcare::FileApi.get_files
    @files = @files_data[:results]
  end
end
