# frozen_string_literal: true

require Rails.root.join("lib/active_storage/variant_uploadcare_remote_processing")

Rails.application.config.to_prepare do
  previewers = Rails.application.config.active_storage.previewers
  previewers.unshift(ActiveStorage::Previewer::UploadcarePreviewer) unless previewers.include?(ActiveStorage::Previewer::UploadcarePreviewer)
  ActiveStorage::Variant.prepend(ActiveStorage::VariantUploadcareRemoteProcessing)
end
