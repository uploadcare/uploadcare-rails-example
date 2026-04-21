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

  def uploadcare_component_config_tag(ctx_name:, **options)
    attributes = Uploadcare::Rails.configuration.uploader_config_attributes
      .transform_keys { |key| key.to_s.tr("_", "-") }
      .merge(options.transform_keys { |key| key.to_s.tr("_", "-") })
      .transform_values { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) ? value.to_s : value }
    attributes["ctx-name"] = ctx_name

    rendered_attributes = attributes.each_with_object(+"") do |(key, value), buffer|
      next if value.nil?

      buffer << %( #{ERB::Util.html_escape(key)}="#{ERB::Util.html_escape(value)}")
    end

    "<uc-config#{rendered_attributes}></uc-config>".html_safe
  end
end
