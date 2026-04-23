# frozen_string_literal: true

module Conversions
  class DocumentConversionInformationController < BaseConversionsController
    def new
      obtain_remote_files
    end

    def show
      result = conversion_formats_from_file
      format_info = result.format.to_h.with_indifferent_access
      @document_format = format_info[:name]
      @document_conversion_formats = Array(format_info[:conversion_formats]).map { |format| format["name"] || format[:name] }
      @document_converted_groups = format_info[:converted_groups]
    end

    private

    def conversion_formats_from_file
      uploadcare_client.conversions.documents.info(uuid: params[:file])
    end
  end
end
