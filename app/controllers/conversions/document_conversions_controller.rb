# frozen_string_literal: true

module Conversions
  class DocumentConversionsController < BaseConversionsController
    def new
      obtain_remote_files
    end

    def create
      result = request_conversion
      flash[:notice] = 'File conversion has been successfully started!'
      redirect_to document_conversion_path(result: result.success)
    rescue Uploadcare::Exception::ConversionError => e
      raise e if throw_error?

      redirect_to document_conversion_path(problem: e.message)
    end

    def show
      @result = params.dig(:result, :result, 0)
      if @result
        token = @result[:token]
        @status_result = check_status(token)
      else
        @problem = parse_problem
      end
    end

    private

    def check_status(token)
      Uploadcare::ConversionApi.get_document_conversion_status(token).success
    end

    def request_conversion
      Uploadcare::ConversionApi.convert_document(
        {
          uuid: document_conversion_params[:file],
          format: document_conversion_params[:target_format].presence,
          page: document_conversion_params[:page].presence
        }.compact,
        store: document_conversion_params[:store]
      )
    end

    def document_conversion_params
      params.permit(:file, :page, :target_format, :throw_error, :store)
    end
  end
end
