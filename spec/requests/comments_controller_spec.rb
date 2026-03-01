# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommentsController, type: :request do
  describe "GET new" do
    it "renders uploader elements" do
      get "/comments/new"

      expect(response).to render_template(:new)
      expect(response.body).to include("uc-file-uploader-regular")
      expect(response.body).to include("uc-form-input")
      expect(response.body).to include("comment[image]")
      expect(response.body).to include("comment[attachments]")
    end
  end
end
