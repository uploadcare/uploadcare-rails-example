# frozen_string_literal: true

require "rails_helper"

RSpec.describe UploadsController, type: :request do
  let(:uploads_accessor) { double("UploadcareUploadsAccessor") }
  let(:client) { double("UploadcareClient", uploads: uploads_accessor) }

  before do
    stub_uploadcare_client(client)
  end

  describe "GET new_local" do
    it "renders a template" do
      get "/upload_new_local_file"

      expect(response).to render_template(:new_local)
    end
  end

  describe "GET upload_new_file_from_url" do
    it "renders a template" do
      get "/upload_new_file_from_url"

      expect(response).to render_template(:new_from_url)
    end
  end

  describe "POST upload_local" do
    let(:file) do
      Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/kitten.jpeg"), "image/jpeg")
    end
    let(:uploaded_file) { Uploadcare::File.new({ "original_filename" => "name", "uuid" => SecureRandom.uuid }, Uploadcare.client) }

    it "uploads a local file" do
      allow(uploads_accessor).to receive(:upload).and_return(uploaded_file)

      post "/upload_local_file",
           params: { file: { file: file, filename: "filename", mime_type: "mime_type", store: "false" } }

      expect(flash[:success]).to match("has been successfully uploaded!")
    end

    it "returns an error on request failure" do
      allow(uploads_accessor).to receive(:upload).and_raise(Uploadcare::Exception::RequestError, "")

      post "/upload_local_file",
           params: { file: { file: file, filename: "filename", mime_type: "mime_type", store: "false" } }

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "POST upload_from_url" do
    let(:url) { "https://ucarecdn.com/26fbb022-4d7a-4dde-9f86-49b29f8407f8/zzz" }
    let(:uploaded_file) { Uploadcare::File.new({ "original_filename" => "name", "uuid" => SecureRandom.uuid }, Uploadcare.client) }

    it "uploads a file from a URL" do
      allow(uploads_accessor).to receive(:upload).and_return(uploaded_file)

      post "/upload_file_from_url", params: { file: { url: url, filename: "filename", store: "false" } }

      expect(flash[:success]).to match("has been successfully uploaded!")
    end

    it "returns an error on request failure" do
      allow(uploads_accessor).to receive(:upload).and_raise(Uploadcare::Exception::RequestError, "")

      post "/upload_file_from_url", params: { file: { url: url, filename: "filename", store: "false" } }

      expect(flash[:alert]).to match("Something went wrong")
    end
  end
end
