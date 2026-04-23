# frozen_string_literal: true

require "rails_helper"

RSpec.describe FileGroupsController, type: :request do
  let(:files_accessor) { double("UploadcareFilesAccessor") }
  let(:groups_accessor) { double("UploadcareGroupsAccessor") }
  let(:client) { Uploadcare::Client.new(public_key: "demopublickey", secret_key: "demoprivatekey") }
  let(:group_id) { "d476f4c9-44a9-4670-88a5-c3cf5d26b6c2~20" }
  let(:file_group) do
    Uploadcare::Group.new(
      {
        "id" => group_id,
        "datetime_created" => "2021-07-16T11:03:01.182939Z",
        "files_count" => 1,
        "cdn_url" => "https://ucarecdn.com/#{group_id}/",
        "url" => "https://api.uploadcare.com/groups/#{group_id}/",
        "files" => [
          {
            "uuid" => "3ae6a420-9de3-4088-9fad-301de9932251",
            "original_filename" => "thumbnail_0.jpg",
            "mime_type" => "image/jpeg"
          }
        ]
      },
      Uploadcare.client
    )
  end

  before do
    allow(client).to receive(:files).and_return(files_accessor)
    allow(client).to receive(:groups).and_return(groups_accessor)
    stub_uploadcare_client(client)
  end

  describe "GET new" do
    it "renders a template" do
      allow(files_accessor).to receive(:list).and_return(uploadcare_paginated)

      get "/file_groups/new"

      expect(response).to render_template(:new)
    end
  end

  describe "GET index" do
    it "returns a 200" do
      allow(groups_accessor).to receive(:list).and_return(uploadcare_paginated)

      get "/file_groups"

      expect(response).to have_http_status(:ok)
    end

    it "returns an error on request failure" do
      allow(groups_accessor).to receive(:list).and_raise(Uploadcare::Exception::RequestError, "")

      get "/file_groups"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "GET show" do
    it "returns a 200" do
      allow(groups_accessor).to receive(:find).with(group_id: group_id).and_return(file_group)

      get "/file_groups/#{group_id}"

      expect(response).to have_http_status(:ok)
    end

    it "wraps group file payloads with the current client" do
      allow(groups_accessor).to receive(:find).with(group_id: group_id).and_return(file_group)
      allow(Uploadcare::File).to receive(:new).and_call_original

      get "/file_groups/#{group_id}"

      expect(Uploadcare::File).to have_received(:new).with(kind_of(Hash), client)
    end

    it "returns an error on request failure" do
      allow(groups_accessor).to receive(:find).with(group_id: group_id).and_raise(Uploadcare::Exception::RequestError, "")

      get "/file_groups/#{group_id}"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "POST store" do
    it "stores a group" do
      allow(groups_accessor).to receive(:find).with(group_id: group_id).and_return(file_group)
      allow(files_accessor).to receive(:batch_store).with(uuids: [ "3ae6a420-9de3-4088-9fad-301de9932251" ])

      post "/store_file_group/#{group_id}"

      expect(flash[:success]).to match("File group has been successfully stored!")
    end
  end

  describe "POST create" do
    it "creates a group" do
      allow(groups_accessor).to receive(:create).with(uuids: [ "3ae6a420-9de3-4088-9fad-301de9932251" ]).and_return(file_group)

      post "/file_groups", params: { files: { file: "3ae6a420-9de3-4088-9fad-301de9932251" } }

      expect(flash[:success]).to match("File group has been successfully created!")
    end

    it "returns an error on request failure" do
      allow(groups_accessor).to receive(:create).with(uuids: [ "3ae6a420-9de3-4088-9fad-301de9932251" ]).and_raise(Uploadcare::Exception::RequestError, "")

      post "/file_groups", params: { files: { file: "3ae6a420-9de3-4088-9fad-301de9932251" } }

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "DELETE destroy" do
    it "deletes a group" do
      allow(groups_accessor).to receive(:find).with(group_id: group_id).and_return(file_group)
      allow(file_group).to receive(:delete)

      delete "/file_groups/#{group_id}"

      expect(response).to redirect_to(file_groups_path)
    end
  end
end
