# frozen_string_literal: true

module ApplicationHelper
  FLASH = {
    'notice' => 'alert alert-info',
    'success' => 'alert alert-success',
    'error' => 'alert alert-error',
    'alert' => 'alert alert-warning'
  }.freeze

  def flash_class(level)
    FLASH.with_indifferent_access[level]
  end
end
