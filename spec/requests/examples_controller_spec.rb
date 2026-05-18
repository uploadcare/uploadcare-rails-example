# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExamplesController, type: :request do
  describe "GET index" do
    it "returns a 200" do
      get "/examples"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Core API operations")
      expect(response.body).to include("Uploader field helper APIs")
    end
  end

  describe "GET uploader_fields" do
    it "renders helper-based uploader fields" do
      get "/examples/uploader_fields"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("post[logo]")
      expect(response.body).to include("post[attachments]")
      expect(response.body).to include("standalone_logo")
      expect(response.body).to include("standalone_attachments")
    end
  end

  describe "POST uploader_fields" do
    it "echoes submitted uploader values" do
      post "/examples/uploader_fields", params: {
        post: {
          logo: "https://ucarecdn.com/logo/",
          attachments: "https://ucarecdn.com/group/"
        },
        standalone_logo: "https://ucarecdn.com/logo-standalone/",
        standalone_attachments: "https://ucarecdn.com/group-standalone/"
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Submitted values")
      expect(response.body).to include("https://ucarecdn.com/logo/")
      expect(response.body).to include("https://ucarecdn.com/group/")
      expect(response.body).to include("https://ucarecdn.com/logo-standalone/")
      expect(response.body).to include("https://ucarecdn.com/group-standalone/")
    end
  end
end
