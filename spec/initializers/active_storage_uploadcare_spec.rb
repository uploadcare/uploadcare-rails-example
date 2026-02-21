# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Uploadcare::Rails ActiveStorage integration" do
  it "registers uploadcare previewer in configured previewers" do
    previewers = Rails.application.config.active_storage.previewers
    expect(previewers).to include(Uploadcare::Rails::ActiveStorage::UploadcarePreviewer)
  end

  it "prepends uploadcare variant processing to ActiveStorage::Variant" do
    expect(ActiveStorage::Variant.ancestors).to include(Uploadcare::Rails::ActiveStorage::VariantRemoteProcessing)
  end
end
