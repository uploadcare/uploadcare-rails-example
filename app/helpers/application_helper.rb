# frozen_string_literal: true

module ApplicationHelper
  FLASH = {
    notice: "uc-alert uc-alert-info",
    success: "uc-alert uc-alert-success",
    error: "uc-alert uc-alert-danger",
    alert: "uc-alert uc-alert-warning"
  }.freeze

  def flash_class(level)
    # Rails flash keys can arrive as strings or symbols depending on caller.
    FLASH[level&.to_sym]
  end

  def menu_link_class(active = false)
    [ "uc-menu-link", ("uc-menu-link-active" if active) ].compact.join(" ")
  end

  def format_date(date, format: "%B %e, %Y %H:%M")
    return if date.blank?

    date = case date
    when String
      Time.zone.parse(date)
    when Date, Time
      date.in_time_zone
    else
      date.in_time_zone if date.respond_to?(:in_time_zone)
    end

    date&.strftime(format)
  rescue ArgumentError
    nil
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
