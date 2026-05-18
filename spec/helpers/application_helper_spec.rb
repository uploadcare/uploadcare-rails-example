# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#flash_class" do
    it "returns the configured class string for known levels" do
      expect(helper.flash_class(:notice)).to eq("alert alert-info")
      expect(helper.flash_class("success")).to eq("alert alert-success")
      expect(helper.flash_class(:error)).to eq("alert alert-danger")
      expect(helper.flash_class("alert")).to eq("alert alert-warning")
    end

    it "returns nil for unknown levels so the partial fallback applies" do
      expect(helper.flash_class(:warning)).to be_nil
      expect(helper.flash_class("info")).to be_nil
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
