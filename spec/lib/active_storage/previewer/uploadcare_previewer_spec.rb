# frozen_string_literal: true

require 'rails_helper'
require 'erb'
require 'yaml'

RSpec.describe ActiveStorage::Previewer::UploadcarePreviewer do
  let(:service_configurations) do
    path = Rails.root.join('config/storage.yml')
    erb = ERB.new(path.read).result
    YAML.safe_load(erb, aliases: true).deep_symbolize_keys
  end
  let(:service) { ActiveStorage::Service.configure(:uploadcare, service_configurations) }
  let(:uuid) { '2d33999d-c74a-4ff9-99ea-abc23496b052' }
  let(:filename) { ActiveStorage::Filename.new('report.pdf') }
  let(:blob) do
    double(
      service: service,
      content_type: 'application/pdf',
      metadata: { 'uploadcare_uuid' => uuid },
      key: 'fallback-key',
      filename: filename
    )
  end

  describe '.accept?' do
    it 'accepts pdf blobs from uploadcare service' do
      expect(described_class.accept?(blob)).to eq(true)
    end

    it 'rejects non-pdf blobs' do
      image_blob = double(service: service, content_type: 'image/png')
      expect(described_class.accept?(image_blob)).to eq(false)
    end

    it 'rejects non-uploadcare services' do
      disk_service = ActiveStorage::Service.configure(:test, service_configurations)
      non_uploadcare_blob = double(service: disk_service, content_type: 'application/pdf')

      expect(described_class.accept?(non_uploadcare_blob)).to eq(false)
    end
  end

  describe '#preview' do
    it 'yields a png attachable hash' do
      previewer = described_class.new(blob)
      allow(Uploadcare::FileApi).to receive(:get_file).with(uuid).and_return(double(cdn_url: "https://ucarecdn.com/#{uuid}/"))

      response = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(response).to receive(:body).and_return('png-preview-data')
      allow(previewer).to receive(:http_get).and_return(response)

      yielded = nil
      previewer.preview do |attachable|
        yielded = attachable
        expect(attachable[:io].read).to eq('png-preview-data')
      end

      expect(yielded[:filename].to_s).to eq('report.png')
      expect(yielded[:content_type]).to eq('image/png')
    end

    it 'uses blob key as uuid fallback when metadata uuid is absent' do
      fallback_blob = double(
        service: service,
        content_type: 'application/pdf',
        metadata: {},
        key: uuid,
        filename: filename
      )
      previewer = described_class.new(fallback_blob)

      allow(Uploadcare::FileApi).to receive(:get_file).with(uuid).and_return(double(cdn_url: "https://ucarecdn.com/#{uuid}/"))
      response = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(response).to receive(:body).and_return('png-preview-data')
      allow(previewer).to receive(:http_get).and_return(response)

      expect { |block| previewer.preview(&block) }.to yield_with_args(hash_including(content_type: 'image/png'))
    end
  end
end
