# frozen_string_literal: true

require "rails_helper"

RSpec.describe Conversions::VideoConversionsController, type: :request do
  let(:files_accessor) { double("UploadcareFilesAccessor") }
  let(:videos_accessor) { double("UploadcareVideoConversionsAccessor") }
  let(:conversions_accessor) { double("UploadcareConversionsAccessor", videos: videos_accessor) }
  let(:video_conversions_api) { double("UploadcareVideoConversionsApi") }
  let(:rest_api) { double("UploadcareRestApi", video_conversions: video_conversions_api) }
  let(:api) { double("UploadcareApi", rest: rest_api) }
  let(:client) { double("UploadcareClient", files: files_accessor, conversions: conversions_accessor, api: api) }
  let(:params) do
    {
      file: "b232bc66-e8e9-4d94-a723-e72dc5264a0f",
      target_format: "ogg",
      quality: "best",
      size: { resize_mode: "change_ratio", width: "200", height: "400" },
      cut: { start_time: "0:0:0.1", length: "end" },
      thumbs: { n: 1, number: 2 },
      throw_error: false,
      store: false
    }
  end

  before do
    stub_uploadcare_client(client)
  end

  describe "GET new" do
    it "renders a template" do
      allow(files_accessor).to receive(:list).and_return(uploadcare_paginated)

      get "/video_conversions/new"

      expect(response).to render_template(:new)
    end
  end

  describe "GET show" do
    it "renders a template for a successful conversion" do
      status_result = double("VideoConversionStatus", status: "finished", error: nil, result: [ { "uuid" => "converted-uuid" } ])
      allow(videos_accessor).to receive(:status).with(token: "21396005").and_return(status_result)

      get video_conversion_path(token: "21396005", original_source: "path", thumbnails_group_uuid: "group-uuid")

      expect(response).to render_template(:show)
    end

    it "renders a template for a failed conversion" do
      get video_conversion_path(problem_source: "path", problem_reason: "Conversion service error.")

      expect(response).to render_template(:show)
    end
  end

  describe "POST create" do
    it "starts a conversion" do
      allow(video_conversions_api).to receive(:convert).and_return(
        Uploadcare::Result.success(
          "result" => [
            {
              "original_source" => "path",
              "token" => "21396005",
              "uuid" => "converted-uuid",
              "thumbnails_group_uuid" => "group-uuid"
            }
          ],
          "problems" => {}
        )
      )

      post "/video_conversions", params: params

      expect(flash[:notice]).to match("File conversion has been successfully started!")
    end

    it "returns an error on request failure" do
      allow(video_conversions_api).to receive(:convert).and_raise(Uploadcare::Exception::RequestError, "")

      post "/video_conversions", params: params

      expect(flash[:alert]).to match("Something went wrong")
    end

    it "raises when throw_error is enabled and problems are returned" do
      allow(video_conversions_api).to receive(:convert).and_return(
        Uploadcare::Result.success("result" => [], "problems" => { "path" => "Conversion service error." })
      )

      expect do
        post "/video_conversions", params: params.merge(throw_error: true)
      end.to raise_error(Uploadcare::Exception::ConversionError)
    end

    it "redirects to show when problems are returned" do
      allow(video_conversions_api).to receive(:convert).and_return(
        Uploadcare::Result.success("result" => [], "problems" => { "path" => "Conversion service error." })
      )

      post "/video_conversions", params: params.except(:throw_error)

      expect(response).to redirect_to(video_conversion_path(problem_source: "path", problem_reason: "Conversion service error."))
    end
  end
end
