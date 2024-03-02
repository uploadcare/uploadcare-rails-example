# frozen_string_literal: true

module ConversionsHelper
  def document_target_formats
    %w[doc docx xls xlsx odt ods rtf txt pdf jpg png enhanced.jpg].map do |format|
      [ format.upcase, format ]
    end
  end

  def video_arget_formats
    %w[ogg webm mp4].map do |format|
      [ format.upcase, format ]
    end
  end

  def video_qualities
    %w[normal better best lighter lightest].map do |quality|
      [ quality.upcase, quality ]
    end
  end

  def video_resize_modes
    %w[preserve_ratio change_ratio scale_crop add_padding].map do |mode|
      [ mode.upcase.tr("_", " "), mode ]
    end
  end
end
