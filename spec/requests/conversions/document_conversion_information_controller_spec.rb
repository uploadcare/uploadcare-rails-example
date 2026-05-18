# frozen_string_literal: true

require "rails_helper"

RSpec.describe Conversions::DocumentConversionInformationController, type: :request do
  let(:files_accessor) { double("UploadcareFilesAccessor") }
  let(:documents_accessor) { double("UploadcareDocumentConversionsAccessor") }
  let(:conversions_accessor) { double("UploadcareConversionsAccessor", documents: documents_accessor) }
  let(:client) { double("UploadcareClient", files: files_accessor, conversions: conversions_accessor) }

  before do
    stub_uploadcare_client(client)
  end

  describe "GET new" do
    it "renders a template" do
      allow(files_accessor).to receive(:list).and_return(uploadcare_paginated)

      get "/document_conversion_information/new"

      expect(response).to render_template(:new)
    end
  end

  describe "GET show" do
    it "renders a template" do
      info = double(
        "DocumentConversionInfo",
        format: {
          "name" => "pdf",
          "conversion_formats" => [ { "name" => "docx" } ],
          "converted_groups" => { "docx" => "group-uuid" }
        }
      )
      allow(documents_accessor).to receive(:info).with(uuid: "file-uuid").and_return(info)

      get "/document_conversion_information", params: { file: "file-uuid" }

      expect(response).to render_template(:show)
    end
  end
end
