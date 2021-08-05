# frozen_string_literal: true

class DocumentConversionsController < ApplicationController
  def new
    obtain_remote_files
  end

  def create
    result = request_conversion
    flash[:success] = 'File has been successfully converted!'
    redirect_to document_conversion_path(result: result.success)
  rescue Uploadcare::Exception::ConversionError => e
    raise e if throw_error?

    redirect_to document_conversion_path(problem: e.message)
  end

  def show
    @result = params.dig(:result, :result, 0)
    if @result
      token = @result[:token]
      @status_result = Uploadcare::ConversionApi.get_document_conversion_status(token).success
    else
      @problem = parse_problem
    end
  end

  private

  def parse_problem
    parsed_problem = JSON.parse(params[:problem].tr(':', '').gsub('=>', ':')).to_a.flatten
    form_problem_result(parsed_problem[0], parsed_problem[1])
  rescue JSON::ParserError, TypeError, NoMethodError
    form_problem_result(nil, params[:problem])
  end

  def form_problem_result(source, reason)
    { original_source: source, reason: reason }
  end

  def throw_error?
    document_conversion_params[:throw_error].present?
  end

  def request_conversion
    Uploadcare::ConversionApi.convert_document(
      {
        uuid: document_conversion_params[:file],
        format: document_conversion_params[:target_format],
        page: document_conversion_params[:page]
      },
      store: document_conversion_params[:store].present?
    )
  end

  def document_conversion_params
    params.permit(:file, :page, :target_format, :throw_error, :store)
  end

  def obtain_remote_files
    @files_data = Uploadcare::FileApi.get_files
    @files = @files_data[:results]
  end
end
