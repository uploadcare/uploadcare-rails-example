# frozen_string_literal: true

module Conversions
  class BaseConversionsController < ApplicationController
    private

    def problem_result_from(problems)
      source, reason = Array(problems).first
      form_problem_result(source, reason)
    end

    def form_problem_result(source, reason)
      { original_source: source, reason: reason }
    end

    def throw_error?
      params[:throw_error].present?
    end

    def conversion_result_entry(payload)
      Array(payload["result"] || payload[:result]).first&.with_indifferent_access
    end

    def conversion_problems(payload)
      (payload["problems"] || payload[:problems] || {}).to_h
    end

    def status_payload(status_result)
      {
        status: status_result.status,
        error: status_result.error,
        result: Array(status_result.result).first&.with_indifferent_access
      }.with_indifferent_access
    end

    def obtain_remote_files
      @files_data = uploadcare_client.files.list(ordering: "-datetime_uploaded")
      @files = @files_data.resources
    end
  end
end
