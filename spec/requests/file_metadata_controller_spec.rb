# frozen_string_literal: true

require "rails_helper"

RSpec.describe FileMetadataController, type: :request do
  let(:files_accessor) { double("UploadcareFilesAccessor") }
  let(:metadata_accessor) { double("UploadcareFileMetadataAccessor") }
  let(:client) { double("UploadcareClient", files: files_accessor, file_metadata: metadata_accessor) }

  before do
    stub_uploadcare_client(client)
  end

  describe "GET index" do
    it "renders a template" do
      allow(files_accessor).to receive(:list).and_return(uploadcare_paginated)

      get "/file_metadata"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET all_metadata_show" do
    it "shows all metadata" do
      allow(metadata_accessor).to receive(:index).with(uuid: "file-uuid").and_return("key" => "value")

      get "/file_metadata/all_metadata_show", params: { uuid: "file-uuid" }

      expect(response).to render_template(:all_metadata_show)
    end
  end

  describe "GET metadata_show" do
    it "shows metadata by key" do
      allow(metadata_accessor).to receive(:show).with(uuid: "file-uuid", key: "key").and_return("value")

      get "/file_metadata/metadata_show", params: { uuid: "file-uuid", key: "key" }

      expect(response).to render_template(:metadata_show)
    end
  end

  describe "PATCH metadata_update" do
    it "updates metadata" do
      allow(metadata_accessor).to receive(:update).with(uuid: "file-uuid", key: "key", value: "value")

      patch "/file_metadata/metadata_update", params: { uuid: "file-uuid", key: "key", value: "value" }

      expect(response).to redirect_to(all_metadata_show_file_metadata_path(uuid: "file-uuid"))
    end
  end

  describe "DELETE metadata_delete" do
    it "deletes metadata" do
      allow(metadata_accessor).to receive(:delete).with(uuid: "file-uuid", key: "key")

      delete "/file_metadata/metadata_delete", params: { uuid: "file-uuid", key: "key" }

      expect(response).to redirect_to(all_metadata_show_file_metadata_path(uuid: "file-uuid"))
    end
  end
end
