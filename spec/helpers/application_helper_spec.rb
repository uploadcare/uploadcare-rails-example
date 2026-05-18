# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#flash_class" do
    it "returns the configured class string for known levels" do
      expect(helper.flash_class(:notice)).to eq("uc-alert uc-alert-info")
      expect(helper.flash_class("success")).to eq("uc-alert uc-alert-success")
      expect(helper.flash_class(:error)).to eq("uc-alert uc-alert-danger")
      expect(helper.flash_class("alert")).to eq("uc-alert uc-alert-warning")
    end

    it "returns nil for unknown levels so the partial fallback applies" do
      expect(helper.flash_class(:warning)).to be_nil
      expect(helper.flash_class("info")).to be_nil
    end
  end

  describe "#menu_link_class" do
    it "returns the active styling when active is true" do
      expect(helper.menu_link_class(true)).to include("uc-menu-link", "uc-menu-link-active")
    end

    it "returns the inactive styling by default" do
      expect(helper.menu_link_class).to eq("uc-menu-link")
    end

    it "returns the inactive styling when active is false" do
      expect(helper.menu_link_class(false)).to eq("uc-menu-link")
    end
  end

  describe "#format_date" do
    it "formats string dates" do
      expect(helper.format_date("2026-05-18T12:30:00Z")).to eq("May 18, 2026 12:30")
    end

    it "formats time-like values without reparsing them" do
      time = Time.zone.parse("2026-05-18T12:30:00Z")

      expect(helper.format_date(time, format: "%Y-%m-%d")).to eq("2026-05-18")
    end

    it "formats date values" do
      date = Date.new(2026, 5, 18)

      expect(helper.format_date(date, format: "%Y-%m-%d")).to eq("2026-05-18")
    end

    it "returns nil for blank dates" do
      expect(helper.format_date(nil)).to be_nil
    end

    it "returns nil for invalid date strings" do
      expect(helper.format_date("not a date")).to be_nil
    end

    it "returns nil for unsupported values" do
      expect(helper.format_date(123)).to be_nil
    end
  end

  describe "#store_options" do
    it "returns explicit store choices for Uploadcare forms" do
      expect(helper.store_options).to eq(
        [
          %w[Yes 1],
          %w[No 0],
          %w[Auto auto]
        ]
      )
    end
  end

  describe "#uploadcare_component_config_tag" do
    it "renders Uploadcare web component attributes using kebab-case names" do
      tag = helper.uploadcare_component_config_tag(ctx_name: "post-logo", img_only: true, locale: "en")

      expect(tag).to include("<uc-config")
      expect(tag).to include('ctx-name="post-logo"')
      expect(tag).to include('img-only="true"')
      expect(tag).to include('locale="en"')
    end
  end
end
