# frozen_string_literal: true

module DocumentConversionsHelper
  def target_formats
    %w[doc docx xls xlsx odt ods rtf txt pdf jpg png].map do |format|
      [format.upcase, format]
    end
  end
end
