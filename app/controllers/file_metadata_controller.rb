# frozen_string_literal: true

class FileMetadataController < ApplicationController
  before_action :set_uuid, except: :index
  before_action :set_key_and_value, only: %i[metadata_show metadata_update metadata_delete]

  def index
    @files_data = uploadcare_client.files.list(ordering: "-datetime_uploaded")
    @files = @files_data.resources
  end

  def all_metadata_show
    @metadata = uploadcare_client.file_metadata.index(uuid: @uuid)
  end

  def metadata_show
    @value = uploadcare_client.file_metadata.show(uuid: @uuid, key: @key)
  end

  def metadata_update
    uploadcare_client.file_metadata.update(uuid: @uuid, key: @key, value: @value)

    redirect_to all_metadata_show_file_metadata_path(uuid: @uuid)
  end

  def metadata_delete
    uploadcare_client.file_metadata.delete(uuid: @uuid, key: @key)
    redirect_to all_metadata_show_file_metadata_path(uuid: @uuid)
  end

  private

  def set_uuid
    @uuid = params[:uuid]
  end

  def set_key_and_value
    @key = params[:key]
    @value = params[:value]
  end
end
