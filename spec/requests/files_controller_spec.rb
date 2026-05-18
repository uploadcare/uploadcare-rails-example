# frozen_string_literal: true

require "rails_helper"

RSpec.describe FilesController, type: :request do
  let(:files_accessor) { double("UploadcareFilesAccessor") }
  let(:client) { double("UploadcareClient", files: files_accessor) }
  let(:uuid) { SecureRandom.uuid }
  let(:file) do
    Uploadcare::File.new(
      {
        "datetime_removed" => nil,
        "datetime_uploaded" => "2018-11-26T12:49:09.945335Z",
        "content_info" => {
          "image" => {
            "color_mode" => "RGB",
            "orientation" => nil,
            "format" => "JPEG",
            "sequence" => false,
            "height" => 500,
            "width" => 500,
            "geo_location" => nil,
            "datetime_original" => nil,
            "dpi" => [ 144, 144 ]
          }
        },
        "is_image" => true,
        "is_ready" => true,
        "mime_type" => "application/octet-stream",
        "original_file_url" => "https://ucarecdn.com/#{uuid}/papaya.jpg",
        "original_filename" => "papaya.jpg",
        "size" => 642,
        "url" => "https://api.uploadcare.com/files/#{uuid}/",
        "uuid" => uuid,
        "variations" => nil,
        "source" => nil,
        "metadata" => { "kind" => "fruit" }
      },
      Uploadcare.client
    )
  end

  before do
    stub_uploadcare_client(client)
  end

  describe "GET index" do
    it "returns a 200" do
      allow(files_accessor).to receive(:list).and_return(uploadcare_paginated)

      get "/files"

      expect(response).to have_http_status(:ok)
    end

    it "returns an error on request failure" do
      allow(files_accessor).to receive(:list).and_raise(Uploadcare::Exception::RequestError, "")

      get "/files"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "GET show" do
    it "returns a 200" do
      allow(files_accessor).to receive(:find).with(uuid: uuid).and_return(file)

      get "/files/#{uuid}"

      expect(response).to have_http_status(:ok)
    end

    it "returns an error on request failure" do
      allow(files_accessor).to receive(:find).with(uuid: uuid).and_raise(Uploadcare::Exception::RequestError, "")

      get "/files/#{uuid}"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "POST copy" do
    it "copies a file" do
      allow(files_accessor).to receive(:copy_to_local).with(source: uuid).and_return(file)

      post "/copy_file/#{uuid}"

      expect(flash[:success]).to match("has been successfully copied")
    end
  end

  describe "POST store" do
    it "stores a file" do
      file_resource = double("UploadcareFile", store: true)
      allow(files_accessor).to receive(:find).with(uuid: uuid).and_return(file_resource)

      post "/store_file/#{uuid}"

      expect(flash[:success]).to match("File has been successfully stored!")
    end

    it "returns an error on request failure" do
      allow(files_accessor).to receive(:find).with(uuid: uuid).and_raise(Uploadcare::Exception::RequestError, "")

      post "/store_file/#{uuid}"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "POST batch store" do
    it "stores files in batch" do
      allow(files_accessor).to receive(:batch_store).with(uuids: [ uuid ])

      post "/store_file_batch", params: { files: { filename: uuid } }

      expect(flash[:success]).to match("has been successfully stored!")
    end

    it "returns an error on request failure" do
      allow(files_accessor).to receive(:batch_store).with(uuids: [ uuid ]).and_raise(Uploadcare::Exception::RequestError, "")

      post "/store_file_batch", params: { files: { filename: uuid } }

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "DELETE destroy" do
    it "deletes a file" do
      file_resource = double("UploadcareFile", delete: true)
      allow(files_accessor).to receive(:find).with(uuid: uuid).and_return(file_resource)

      delete "/files/#{uuid}"

      expect(flash[:success]).to match("File has been successfully deleted!")
    end

    it "returns an error on request failure" do
      allow(files_accessor).to receive(:find).with(uuid: uuid).and_raise(Uploadcare::Exception::RequestError, "")

      delete "/files/#{uuid}"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "DELETE batch delete" do
    it "deletes files in batch" do
      allow(files_accessor).to receive(:batch_delete).with(uuids: [ uuid ])

      delete "/delete_file_batch", params: { files: { filename: uuid } }

      expect(flash[:success]).to match("has been successfully deleted!")
    end

    it "returns an error on request failure" do
      allow(files_accessor).to receive(:batch_delete).with(uuids: [ uuid ]).and_raise(Uploadcare::Exception::RequestError, "")

      delete "/delete_file_batch", params: { files: { filename: uuid } }

      expect(flash[:alert]).to match("Something went wrong")
    end
  end
end
