# frozen_string_literal: true

class FileMetadataController < ApplicationController
  before_action :set_uuid, expect: :index
  before_action :set_key_and_value, only: %i[metadata_show metadata_update]

  def index
    @files_data = Uploadcare::FileApi.get_files(ordering: '-datetime_uploaded')
    @files = @files_data[:results]
  end
  
  def all_metadata_show
    @metadata = Uploadcare::FileMetadata.index(@uuid)
  rescue JSON::ParserError
    Uploadcare::FileMetadata.update(@uuid, 'test-key', 'test-value')
    @metadata = Uploadcare::FileMetadata.index(@uuid)
  end

  def metadata_show
    @value = Uploadcare::FileMetadata.show(@uuid, @key)
  end

  def metadata_update
    Uploadcare::FileMetadata.update(@uuid, @key, @value)

    redirect_to all_metadata_show_file_metadata_path(uuid: @uuid)
  end
  
  def metadata_delete
    key = params[:key]
    Uploadcare::FileMetadata.delete(@uuid, key)

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
