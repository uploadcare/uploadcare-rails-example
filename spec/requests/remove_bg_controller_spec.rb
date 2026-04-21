# frozen_string_literal: true

require "rails_helper"

RSpec.describe RemoveBgController, type: :request do
  let(:files_accessor) { double("UploadcareFilesAccessor") }
  let(:addons_accessor) { double("UploadcareAddonsAccessor") }
  let(:client) { double("UploadcareClient", files: files_accessor, addons: addons_accessor) }

  before do
    stub_uploadcare_client(client)
  end

  describe "GET new" do
    it "renders a template" do
      allow(files_accessor).to receive(:list).and_return(uploadcare_paginated)

      get "/remove_bg/new"

      expect(response).to render_template(:new)
    end
  end

  describe "POST create" do
    it "starts background removal" do
      result = double("AddonExecution", request_id: "request-id")
      allow(addons_accessor).to receive(:remove_bg).with(
        uuid: "file-uuid",
        params: { "crop" => "1" }
      ).and_return(result)

      post "/remove_bg", params: { file: "file-uuid", options: { crop: "1" } }

      expect(response).to redirect_to(remove_bg_index_path(uuid: "request-id"))
    end

    it "starts background removal without optional params" do
      result = double("AddonExecution", request_id: "request-id")
      allow(addons_accessor).to receive(:remove_bg).with(
        uuid: "file-uuid",
        params: {}
      ).and_return(result)

      post "/remove_bg", params: { file: "file-uuid" }

      expect(response).to redirect_to(remove_bg_index_path(uuid: "request-id"))
    end
  end

  describe "GET check_status" do
    it "checks background removal status" do
      result = double("AddonExecution", status: "done")
      allow(addons_accessor).to receive(:remove_bg_status).with(request_id: "request-id").and_return(result)

      get "/remove_bg/check_status", params: { uuid: "request-id" }

      expect(response).to redirect_to(show_status_remove_bg_index_path(status: "done"))
    end
  end
end
