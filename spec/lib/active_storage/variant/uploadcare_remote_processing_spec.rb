# frozen_string_literal: true

require 'rails_helper'
require 'erb'
require 'yaml'

RSpec.describe ActiveStorage::Variant do
  let(:service_configurations) do
    path = Rails.root.join('config/storage.yml')
    erb = ERB.new(path.read).result
    YAML.safe_load(erb, aliases: true).deep_symbolize_keys
  end
  let(:uploadcare_service) { ActiveStorage::Service.configure(:uploadcare, service_configurations) }
  let(:uuid) { '2d33999d-c74a-4ff9-99ea-abc23496b052' }
  let(:blob) do
    double(
      service: uploadcare_service,
      metadata: { 'uploadcare_uuid' => uuid },
      key: 'blob-key',
      filename: ActiveStorage::Filename.new('image.jpg')
    )
  end

  describe '#processed with uploadcare service' do
    it 'downloads transformed image from uploadcare and uploads variant to service' do
      variant = described_class.new(blob, resize_to_limit: [ 320, 320 ], quality: "smart")

      allow(uploadcare_service).to receive(:exist?).with(variant.key).and_return(false)
      allow(uploadcare_service).to receive(:upload)

      file = instance_double(Uploadcare::Rails::File)
      allow(Uploadcare::Rails::File).to receive(:new).with({ uuid: uuid }).and_return(file)
      allow(file).to receive(:transform_url).with(hash_including(resize: "320x320", quality: "smart")).and_return("https://ucarecdn.com/#{uuid}/-/resize/320x320/-/quality/smart/")

      response = Net::HTTPOK.new("1.1", "200", "OK")
      allow(response).to receive(:body).and_return("transformed-bytes")

      http = instance_double(Net::HTTP)
      allow(http).to receive(:request).and_return(response)
      allow(Net::HTTP).to receive(:start).and_yield(http)

      variant.processed

      expect(uploadcare_service).to have_received(:upload).with(variant.key, anything, content_type: variant.content_type)
    end
  end
end
