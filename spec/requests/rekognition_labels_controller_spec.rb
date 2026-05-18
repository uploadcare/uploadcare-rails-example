# frozen_string_literal: true

require "rails_helper"

RSpec.describe RekognitionLabelsController, type: :request do
  let(:files_accessor) { double("UploadcareFilesAccessor") }
  let(:addons_accessor) { double("UploadcareAddonsAccessor") }
  let(:client) { double("UploadcareClient", files: files_accessor, addons: addons_accessor) }

  before do
    stub_uploadcare_client(client)
  end

  describe "GET new" do
    it "renders a template" do
      allow(files_accessor).to receive(:list).and_return(uploadcare_paginated)

      get "/rekognition_labels/new"

      expect(response).to render_template(:new)
    end
  end

  describe "POST create" do
    it "starts label detection" do
      result = double("AddonExecution", request_id: "request-id")
      allow(addons_accessor).to receive(:aws_rekognition_detect_labels).and_return(result)

      post "/rekognition_labels", params: { file: "file-uuid" }

      expect(response).to redirect_to(rekognition_labels_path(uuid: "request-id"))
    end
  end

  describe "GET check_status" do
    it "checks label detection status" do
      result = double("AddonExecution", status: "done")
      allow(addons_accessor).to receive(:aws_rekognition_detect_labels_status).with(request_id: "request-id").and_return(result)

      get "/rekognition_labels/check_status", params: { uuid: "request-id" }

      expect(response).to redirect_to(show_status_rekognition_labels_path(status: "done"))
    end
  end
end
