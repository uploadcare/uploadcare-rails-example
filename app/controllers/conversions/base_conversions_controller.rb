# frozen_string_literal: true

module Conversions
  class BaseConversionsController < ApplicationController
    private

    def parse_problem
      parsed_problem = JSON.parse(params[:problem].tr(":", "").gsub("=>", ":")).to_a.flatten
      form_problem_result(parsed_problem[0], parsed_problem[1])
    rescue JSON::ParserError, TypeError, NoMethodError
      form_problem_result(nil, params[:problem])
    end

    def form_problem_result(source, reason)
      { original_source: source, reason: reason }
    end

    def throw_error?
      params[:throw_error].present?
    end

    def obtain_remote_files
      @files_data = Uploadcare::FileApi.get_files(ordering: "-datetime_uploaded")
      @files = @files_data[:results]
    end
  end
end
