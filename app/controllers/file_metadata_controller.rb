# frozen_string_literal: true

class FileMetadataController < ApplicationController
  before_action :set_uuid, expect: :index
  before_action :set_key_and_value, only: %i[metadata_show metadata_update]

  def index
    @files_data = Uploadcare::FileApi.get_files(ordering: '-datetime_uploaded')
    @files = @files_data[:results]
  end

  def all_metadata_show
    @metadata = Uploadcare::FileMetadataApi.file_metadata(@uuid)
  rescue JSON::ParserError
    Uploadcare::FileMetadataApi.update_file_metadata(@uuid, 'test-key', 'test-value')
    @metadata = Uploadcare::FileMetadataApi.file_metadata(@uuid)
  end

  def metadata_show
    @value = Uploadcare::FileMetadataApi.file_metadata_value(@uuid, @key)
  end

  def metadata_update
    Uploadcare::FileMetadataApi.update_file_metadata(@uuid, @key, @value)

    redirect_to all_metadata_show_file_metadata_path(uuid: @uuid)
  end

  def metadata_delete
    key = params[:key]
    Uploadcare::FileMetadataApi.delete_file_metadata(@uuid, key)

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
