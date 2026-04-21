# frozen_string_literal: true

module Conversions
  class DocumentConversionsController < BaseConversionsController
    def new
      obtain_remote_files
    end

    def create
      result = request_conversion
      problems = conversion_problems(result)

      if problems.present?
        raise Uploadcare::Exception::ConversionError, problems.inspect if throw_error?

        problem = problem_result_from(problems)
        redirect_to document_conversion_path(problem_source: problem[:original_source], problem_reason: problem[:reason])
      elsif uploadcare_bool(document_conversion_params[:save_in_group])
        flash[:notice] = "File conversion has successfully started! The group shall be available in the Converted Groups section for selected format. Please refresh the page in some time to see the converted group."
        redirect_to document_conversion_information_path(file: document_conversion_params[:file])
      else
        entry = conversion_result_entry(result)
        flash[:notice] = "File conversion has successfully started!"
        redirect_to document_conversion_path(
          token: entry[:token],
          original_source: entry[:original_source]
        )
      end
    end

    def show
      if params[:token].present?
        @result = { original_source: params[:original_source] }.with_indifferent_access
        @status_result = status_payload(check_status(params[:token]))
      else
        @problem = form_problem_result(params[:problem_source], params[:problem_reason])
      end
    end

    private

    def check_status(token)
      uploadcare_client.conversions.documents.status(token: token)
    end

    def request_conversion
      Uploadcare::Result.unwrap(
        uploadcare_client.api.rest.document_conversions.convert(
          paths: [ document_conversion_path_value ],
          options: {
            store: uploadcare_bool(document_conversion_params[:store]),
            save_in_group: uploadcare_bool(document_conversion_params[:save_in_group])
          }.compact
        )
      )
    end

    def document_conversion_path_value
      path = "#{document_conversion_params[:file]}/document/-/format/#{document_conversion_params[:target_format]}/"
      page = document_conversion_params[:page].presence
      path += "-/page/#{page}/" if page
      path
    end

    def document_conversion_params
      params.permit(:file, :page, :target_format, :throw_error, :store, :save_in_group)
    end
  end
end
