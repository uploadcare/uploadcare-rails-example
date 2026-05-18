# frozen_string_literal: true

require "rails_helper"

RSpec.describe Conversions::DocumentConversionsController, type: :request do
  let(:files_accessor) { double("UploadcareFilesAccessor") }
  let(:document_conversions_accessor) { double("UploadcareDocumentConversionsAccessor") }
  let(:conversions_accessor) { double("UploadcareConversionsAccessor", documents: document_conversions_accessor) }
  let(:document_conversions_api) { double("UploadcareDocumentConversionsApi") }
  let(:rest_api) { double("UploadcareRestApi", document_conversions: document_conversions_api) }
  let(:api) { double("UploadcareApi", rest: rest_api) }
  let(:client) { double("UploadcareClient", files: files_accessor, conversions: conversions_accessor, api: api) }
  let(:params) do
    { file: "b232bc66-e8e9-4d94-a723-e72dc5264a0f", target_format: "doc", throw_error: false, store: false }
  end

  before do
    stub_uploadcare_client(client)
  end

  describe "GET new" do
    it "renders a template" do
      allow(files_accessor).to receive(:list).and_return(uploadcare_paginated)

      get "/document_conversions/new"

      expect(response).to render_template(:new)
    end
  end

  describe "GET show" do
    it "renders a template for a successful conversion" do
      status_result = double("DocumentConversionStatus", status: "finished", error: nil, result: [ { "uuid" => "converted-uuid" } ])
      allow(document_conversions_accessor).to receive(:status).with(token: "21396005").and_return(status_result)

      get document_conversion_path(token: "21396005", original_source: "path")

      expect(response).to render_template(:show)
    end

    it "renders a template for a failed conversion" do
      get document_conversion_path(problem_source: "path", problem_reason: "CDN Path error.")

      expect(response).to render_template(:show)
    end
  end

  describe "POST create" do
    it "starts a conversion" do
      allow(document_conversions_api).to receive(:convert).and_return(
        Uploadcare::Result.success(
          "result" => [ { "original_source" => "path", "token" => "21396005", "uuid" => "converted-uuid" } ],
          "problems" => {}
        )
      )

      post "/document_conversions", params: params

      expect(flash[:notice]).to match("File conversion has successfully started!")
    end

    it "redirects to the info page when saving in group" do
      allow(document_conversions_api).to receive(:convert).and_return(
        Uploadcare::Result.success("result" => [ { "token" => "21396005" } ], "problems" => {})
      )

      post "/document_conversions", params: params.merge(save_in_group: "1")

      expect(response).to redirect_to(document_conversion_information_path(file: params[:file]))
    end

    it "returns an error on request failure" do
      allow(document_conversions_api).to receive(:convert).and_raise(Uploadcare::Exception::RequestError, "")

      post "/document_conversions", params: params

      expect(flash[:alert]).to match("Something went wrong")
    end

    it "raises when throw_error is enabled and problems are returned" do
      allow(document_conversions_api).to receive(:convert).and_return(
        Uploadcare::Result.success("result" => [], "problems" => { "path" => "CDN Path error." })
      )

      expect do
        post "/document_conversions", params: params.merge(throw_error: true)
      end.to raise_error(Uploadcare::Exception::ConversionError)
    end

    it "redirects to show when problems are returned" do
      allow(document_conversions_api).to receive(:convert).and_return(
        Uploadcare::Result.success("result" => [], "problems" => { "path" => "CDN Path error." })
      )

      post "/document_conversions", params: params.except(:throw_error)

      expect(response).to redirect_to(document_conversion_path(problem_source: "path", problem_reason: "CDN Path error."))
    end
  end
end
