# frozen_string_literal: true

module Conversions
  class DocumentConversionsController < BaseConversionsController
    def new
      obtain_remote_files
    end

    def create
      result = request_conversion
      if document_conversion_params[:save_in_group] == "1"
        flash[:notice] = "File conversion has successfully started! The group shall be available in the Converted Groups section for selected format. Please refresh the page in some time to see the converted group."
        redirect_to document_conversion_information_path(file: document_conversion_params[:file])
      else
        flash[:notice] = "File conversion has successfully started!"
        redirect_to document_conversion_path(result: result.success)
      end
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
        {
          store: document_conversion_params[:store],
          save_in_group: document_conversion_params[:save_in_group]
        }.compact
      )
    end

    def document_conversion_params
      params.permit(:file, :page, :target_format, :throw_error, :store, :save_in_group)
    end
  end
end
