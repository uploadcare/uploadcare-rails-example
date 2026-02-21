# frozen_string_literal: true

require 'rails_helper'
require 'stringio'
require 'base64'
require 'digest'
require 'erb'
require 'yaml'

RSpec.describe 'ActiveStorage Uploadcare service', type: :model do
  let(:service_configurations) do
    path = Rails.root.join('config/storage.yml')
    erb = ERB.new(path.read).result
    YAML.safe_load(erb, aliases: true).deep_symbolize_keys
  end
  let(:service) { ActiveStorage::Service.configure(:uploadcare, service_configurations) }
  let(:uuid) { '2d33999d-c74a-4ff9-99ea-abc23496b052' }

  it 'builds Uploadcare active storage service from storage.yml' do
    expect(service).to be_a(ActiveStorage::Service::UploadcareService)
  end

  it 'uploads through uploadcare service API adapter' do
    uploadcare_file = double(uuid: uuid)
    io = StringIO.new('active storage payload')
    checksum = Base64.strict_encode64(Digest::MD5.digest(io.read))
    io.rewind

    allow(Uploadcare::Uploader).to receive(:upload_file).and_return(uploadcare_file)
    allow(Uploadcare::File).to receive(:info).with(uuid: uuid, config: kind_of(Uploadcare::Configuration)).and_return(double)

    service.upload('example-key', io, checksum: checksum)

    expect(service.exist?('example-key')).to eq(true)
  end
end
