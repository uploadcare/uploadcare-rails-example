# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActiveStorage Uploadcare initializer' do
  it 'registers uploadcare previewer in configured previewers' do
    previewers = Rails.application.config.active_storage.previewers

    expect(previewers).to include(ActiveStorage::Previewer::UploadcarePreviewer)
  end

  it 'prepends uploadcare variant processing to ActiveStorage::Variant' do
    expect(ActiveStorage::Variant.ancestors).to include(ActiveStorage::VariantUploadcareRemoteProcessing)
  end
end
