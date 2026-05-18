# frozen_string_literal: true

require "rails_helper"

RSpec.describe VirusScanController, type: :request do
  let(:files_accessor) { double("UploadcareFilesAccessor") }
  let(:addons_accessor) { double("UploadcareAddonsAccessor") }
  let(:client) { double("UploadcareClient", files: files_accessor, addons: addons_accessor) }

  before do
    stub_uploadcare_client(client)
  end

  describe "GET new" do
    it "renders a template" do
      allow(files_accessor).to receive(:list).and_return(uploadcare_paginated)

      get "/virus_scan/new"

      expect(response).to render_template(:new)
    end
  end

  describe "POST create" do
    it "starts a virus scan" do
      result = double("AddonExecution", request_id: "request-id")
      allow(addons_accessor).to receive(:uc_clamav_virus_scan).and_return(result)

      post "/virus_scan", params: { file: "file-uuid", purge_infected: "1" }

      expect(response).to redirect_to(virus_scan_index_path(uuid: "request-id"))
    end
  end

  describe "GET check_status" do
    it "checks scan status" do
      result = double("AddonExecution", status: "done")
      allow(addons_accessor).to receive(:uc_clamav_virus_scan_status).with(request_id: "request-id").and_return(result)

      get "/virus_scan/check_status", params: { uuid: "request-id" }

      expect(response).to redirect_to(show_status_virus_scan_index_path(status: "done"))
    end
  end
end
