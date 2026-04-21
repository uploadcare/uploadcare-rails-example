# frozen_string_literal: true

module Conversions
  class VideoConversionsController < BaseConversionsController
    def new
      obtain_remote_files
    end

    def create
      result = request_conversion
      problems = conversion_problems(result)

      if problems.present?
        raise Uploadcare::Exception::ConversionError, problems.inspect if throw_error?

        problem = problem_result_from(problems)
        redirect_to video_conversion_path(problem_source: problem[:original_source], problem_reason: problem[:reason])
      else
        conversion_entry = conversion_result_entry(result) || {}
        flash[:notice] = "File conversion has been successfully started!"
        redirect_to video_conversion_path(
          token: conversion_entry[:token],
          original_source: conversion_entry[:original_source],
          thumbnails_group_uuid: conversion_entry[:thumbnails_group_uuid]
        )
      end
    end

    def show
      if params[:token].present?
        @result = {
          original_source: params[:original_source],
          thumbnails_group_uuid: params[:thumbnails_group_uuid]
        }.with_indifferent_access
        @status_result = status_payload(uploadcare_client.conversions.videos.status(token: params[:token]))
      else
        @problem = form_problem_result(params[:problem_source], params[:problem_reason])
      end
    end

    private

    def request_conversion
      Uploadcare::Result.unwrap(
        uploadcare_client.api.rest.video_conversions.convert(
          paths: [ conversion_path_value ],
          options: { store: uploadcare_bool(video_conversion_params[:store]) }
        )
      )
    end

    def conversion_path_value
      hashed_params = video_conversion_params.to_h
      path = "#{hashed_params[:file]}/video/"
      size = size_params(hashed_params)
      cut = cut_params(hashed_params)
      thumbs = thumbs_params(hashed_params)

      if size.present?
        dimensions = [ size[:width], size[:height] ].join("x")
        path += "-/size/#{dimensions}/#{size[:resize_mode]}/"
      end
      path += "-/format/#{hashed_params[:target_format]}/" if hashed_params[:target_format].present?
      path += "-/quality/#{hashed_params[:quality]}/" if hashed_params[:quality].present?
      if cut.present?
        path += "-/cut/#{cut[:start_time]}/#{cut[:length]}/"
      end
      if thumbs.present?
        path += "-/thumbs~#{thumbs[:number]}/#{thumbs[:N]}/"
      end

      path
    end

    def thumbs_params(hashed_params)
      filter_blank(
        N: hashed_params.dig(:thumbs, :n),
        number: hashed_params.dig(:thumbs, :number)
      )
    end

    def cut_params(hashed_params)
      filter_blank(
        start_time: hashed_params.dig(:cut, :start_time),
        length: hashed_params.dig(:cut, :length)
      )
    end

    def size_params(hashed_params)
      filter_blank(
        resize_mode: hashed_params.dig(:size, :resize_mode),
        width: hashed_params.dig(:size, :width),
        height: hashed_params.dig(:size, :height)
      )
    end

    def filter_blank(element)
      case element
      when Hash
        element.map do |key, value|
          new_value = filter_blank(value)
          next unless new_value

          [ key, new_value ]
        end.compact.to_h.presence
      when Array
        element.reject(&:blank?).presence
      else
        element.presence
      end
    end

    def video_conversion_params
      params.permit(:file, :target_format, :quality, :store, :throw_error, size: {}, cut: {}, thumbs: {})
    end
  end
end
