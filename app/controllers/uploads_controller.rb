# frozen_string_literal: true

class UploadsController < ApplicationController
  def new_local; end

  def new_from_url; end

  def upload_local
    file = local_file_with_custom_params
    uploaded_file = Uploadcare::UploadApi.upload_file(file, store: file_params[:store].present?)
    flash[:success] = "File '#{uploaded_file.original_filename}' has been successfully uploaded!"
    redirect_to upload_new_local_file_path
  end

  def upload_from_url
    url = file_params[:url]
    files = Uploadcare::UploadApi.upload_file(
      url,
      **{
        filename: file_params[:filename].presence,
        store: file_params[:store].present?
      }.compact
    )
    flash[:success] = "File '#{files[0].original_filename}' has been successfully uploaded!"
    redirect_to upload_new_file_from_url_path
  end

  private

  def local_file_with_custom_params
    file = file_params[:file]
    file.original_filename = file_params[:filename] if file_params[:filename].present?
    file.content_type = file_params[:mime_type] if file_params[:mime_type].present?
    file
  end

  def file_params
    params.require(:file).permit(:file, :mime_type, :filename, :store, :url)
  end
end
