# frozen_string_literal: true

module Conversions
  class DocumentConversionInformationController < BaseConversionsController
    def new
      obtain_remote_files
    end

    def show
      @result = conversion_formats_from_file
      @document_format = @result.dig(:format, :name)
      @document_conversion_formats = @result.dig(:format, :conversion_formats).map { |format| format[:name] }
      @document_converted_groups = @result.dig(:format, :converted_groups)
    end

    private

    def conversion_formats_from_file
      Uploadcare::ConversionApi.get_document_conversion_formats_info(params[:file]).success
    end
  end
end
