# frozen_string_literal: true

module ApplicationHelper
  FLASH = {
    "notice" => "alert alert-info",
    "success" => "alert alert-success",
    "error" => "alert alert-error",
    "alert" => "alert alert-warning"
  }.freeze

  def flash_class(level)
    FLASH.with_indifferent_access[level]
  end

  def format_date(date, format: "%B %e, %Y %H:%M")
    Time.zone.parse(date).strftime(format)
  end

  def store_options
    [
      %w[Yes 1],
      %w[No 0],
      %w[Auto auto]
    ]
  end
end
