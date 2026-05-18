# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommentsController, type: :request do
  let(:comment_object) { create :comment }

  describe "GET index" do
    it "returns a 200" do
      comment_object

      get "/comments"

      expect(response.body).to match(comment_object.content)
    end
  end

  describe "GET new" do
    it "renders uploader elements" do
      get "/comments/new"

      expect(response).to render_template(:new)
      expect(response.body).to include("uc-file-uploader-regular")
      expect(response.body).to include("uc-form-input")
      expect(response.body).to include("comment[image]")
      expect(response.body).to include("comment[attachments]")
      expect(response.body).to include('multiple="true"')
      expect(response.body).to include('group-output="true"')
    end
  end

  describe "GET edit" do
    it "renders a template" do
      get "/comments/#{comment_object.id}/edit"

      expect(response).to render_template(:edit)
    end

    it "preloads uploader values" do
      get "/comments/#{comment_object.id}/edit"

      expect(response.body).to include(%(value="#{comment_object.image}"))
      expect(response.body).to include(%(value="#{comment_object.attachments}"))
    end
  end

  describe "GET show" do
    it "returns a 200" do
      allow_any_instance_of(Uploadcare::Rails::AttachedFile).to receive(:load).and_return(
        Uploadcare::Rails::AttachedFile.new(
          {
            "uuid" => "image-uuid",
            "cdn_url" => "https://ucarecdn.com/image-uuid/",
            "original_filename" => "image.svg",
            "mime_type" => "image/svg+xml"
          }
        )
      )
      allow_any_instance_of(CommentsController).to receive(:load_group_files).and_return([])

      get "/comments/#{comment_object.id}"

      expect(response).to render_template(:show)
    end

    it "returns an error when attachment loading fails" do
      allow_any_instance_of(CommentsController).to receive(:load_group_files).and_raise(Uploadcare::Exception::RequestError, "")

      get "/comments/#{comment_object.id}"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "POST create" do
    it "creates a comment" do
      expect do
        post "/comments", params: {
          comment: { content: "Created comment", image: "https://imageurl.com", attachments: "https://attachmentsurl.com" }
        }
      end.to change(Comment, :count).by(1)
    end

    it "returns comment errors" do
      expect do
        post "/comments", params: {
          comment: { content: "", image: "https://imageurl.com", attachments: "https://attachmentsurl.com" }
        }
      end.not_to change(Comment, :count)

      expect(flash[:alert]).to match("Content can't be blank")
    end
  end

  describe "PATCH update" do
    it "updates a comment" do
      expect do
        patch "/comments/#{comment_object.id}", params: {
          comment: {
            content: comment_object.content.reverse,
            image: "#{comment_object.image}/new",
            attachments: "#{comment_object.attachments}/new"
          }
        }
      end.to change { comment_object.reload.content }
    end

    it "returns comment errors" do
      old_values = comment_object.attributes.slice("content", "image", "attachments")

      patch "/comments/#{comment_object.id}", params: {
        comment: { content: "", image: "#{comment_object.image}/new", attachments: "#{comment_object.attachments}/new" }
      }

      expect(comment_object.reload.attributes.slice("content", "image", "attachments")).to eq(old_values)
      expect(flash[:alert]).to match("Content can't be blank")
    end
  end

  describe "DELETE destroy" do
    it "deletes a comment" do
      comment_object

      expect { delete "/comments/#{comment_object.id}" }.to change(Comment, :count).by(-1)
    end
  end
end
