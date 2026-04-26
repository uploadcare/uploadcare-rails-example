# frozen_string_literal: true

module ApplicationHelper
  FLASH = {
    "notice" => "rounded-md border border-sky-200 bg-sky-50 px-4 py-3 text-sm text-sky-900",
    "success" => "rounded-md border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-900",
    "error" => "rounded-md border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-900",
    "alert" => "rounded-md border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900"
  }.freeze

  def flash_class(level)
    FLASH.with_indifferent_access[level]
  end

  def sidebar_link_class(active)
    [
      "block rounded-md px-3 py-2 text-sm font-medium transition",
      active ? "bg-slate-900 text-white" : "text-slate-700 hover:bg-slate-100 hover:text-slate-950"
    ].join(" ")
  end

  def sidebar_section_class
    "px-3 pt-5 pb-2 text-xs font-semibold uppercase tracking-wide text-slate-500"
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
