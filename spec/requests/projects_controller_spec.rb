# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectsController, type: :request do
  let(:project_accessor) { double("UploadcareProjectAccessor") }
  let(:client) { double("UploadcareClient", project: project_accessor) }
  let(:project) do
    Uploadcare::Project.new(
      {
        "collaborators" => [ { "name" => "Mike", "email" => "mike@mail.com" } ],
        "name" => "Hello, World!",
        "pub_key" => "demopublickey",
        "autostore_enabled" => true
      },
      Uploadcare.client
    )
  end

  before do
    stub_uploadcare_client(client)
  end

  describe "GET show" do
    it "returns a 200" do
      allow(project_accessor).to receive(:current).and_return(project)

      get "/project"

      expect(response).to have_http_status(:ok)
    end

    it "returns an error on request failure" do
      allow(project_accessor).to receive(:current).and_raise(Uploadcare::Exception::RequestError, "")

      get "/project"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end
end
