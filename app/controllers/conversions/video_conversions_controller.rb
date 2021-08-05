# frozen_string_literal: true

module Conversions
  class VideoConversionsController < BaseConversionsController
    def new
      obtain_remote_files
    end

    def create
      result = request_conversion
      flash[:notice] = 'File conversion has been successfully started!'
      redirect_to video_conversion_path(result: result.success)
    rescue Uploadcare::Exception::ConversionError => e
      raise e if throw_error?

      redirect_to video_conversion_path(problem: e.message)
    end

    def show
      @result = params.dig(:result, :result, 0)
      if @result
        token = @result[:token]
        @status_result = Uploadcare::ConversionApi.get_video_conversion_status(token).success
      else
        @problem = parse_problem
      end
    end

    private

    def redirect_to_prev_location(message)
      flash[:alert] = message
      redirect_to video_conversion_path(problem: message)
    end

    def request_conversion
      Uploadcare::ConversionApi.convert_video(
        conversion_params,
        store: video_conversion_params[:store].present?
      )
    end

    def conversion_params
      hashed_params = video_conversion_params.to_h
      filter_blank(
        uuid: hashed_params[:file],
        size: hashed_params[:size],
        format: hashed_params[:target_format],
        quality: hashed_params[:quality],
        cut: hashed_params[:cut],
        thumbs: {
          N: hashed_params.dig(:thumbs, :n),
          number: hashed_params.dig(:thumbs, :number)
        }
      )
    end

    def filter_blank(element)
      case element
      when Hash
        element.map do |key, value|
          new_value = filter_blank(value)
          next unless new_value

          [key, new_value]
        end.compact.to_h.presence
      when Array
        element.reject(&:blank?).presence
      else
        element.presence
      end
    end

    def video_conversion_params
      params.permit(:file, :target_format, :quality, :store, size: {}, cut: {}, thumbs: {})
    end
  end
end
