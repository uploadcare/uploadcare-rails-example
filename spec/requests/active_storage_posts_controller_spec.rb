# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveStoragePostsController, type: :request do
  let(:active_storage_post) { create :active_storage_post }
  let(:cover_image) { fixture_file_upload(Rails.root.join("spec/fixtures/files/cover.svg"), "image/svg+xml") }
  let(:notes_file) { fixture_file_upload(Rails.root.join("spec/fixtures/files/notes.txt"), "text/plain") }
  let(:checklist_file) { fixture_file_upload(Rails.root.join("spec/fixtures/files/checklist.txt"), "text/plain") }

  describe "GET index" do
    it "returns a 200" do
      active_storage_post

      get "/active_storage_posts"

      expect(response.body).to match(active_storage_post.title)
    end
  end

  describe "GET new" do
    it "renders a template with file inputs" do
      get "/active_storage_posts/new"

      expect(response).to render_template(:new)
      expect(response.body).to include('type="file"')
      expect(response.body).to include('name="active_storage_post[cover_image]"')
      expect(response.body).to include('name="active_storage_post[attachments][]"')
    end
  end

  describe "GET edit" do
    it "renders a template" do
      get "/active_storage_posts/#{active_storage_post.id}/edit"

      expect(response).to render_template(:edit)
    end
  end

  describe "GET show" do
    it "renders attached file details" do
      active_storage_post.cover_image.attach(io: File.open(Rails.root.join("spec/fixtures/files/cover.svg")), filename: "cover.svg", content_type: "image/svg+xml")
      active_storage_post.attachments.attach(io: File.open(Rails.root.join("spec/fixtures/files/notes.txt")), filename: "notes.txt", content_type: "text/plain")

      get "/active_storage_posts/#{active_storage_post.id}"

      expect(response).to render_template(:show)
      expect(response.body).to include("cover.svg")
      expect(response.body).to include("notes.txt")
      expect(response.body).to include("test")
    end
  end

  describe "POST create" do
    it "creates an Active Storage post with one and many attachments" do
      expect do
        post "/active_storage_posts", params: {
          active_storage_post: {
            title: "Created from request spec",
            cover_image: cover_image,
            attachments: [ notes_file, checklist_file ]
          }
        }
      end.to change(ActiveStoragePost, :count).by(1)

      created_post = ActiveStoragePost.order(:created_at).last

      expect(created_post.cover_image).to be_attached
      expect(created_post.attachments.count).to eq(2)
    end

    it "returns validation errors" do
      expect do
        post "/active_storage_posts", params: {
          active_storage_post: {
            title: "",
            cover_image: cover_image,
            attachments: [ notes_file ]
          }
        }
      end.not_to change(ActiveStoragePost, :count)

      expect(flash[:alert]).to match("Title can't be blank")
    end
  end

  describe "PATCH update" do
    before do
      active_storage_post.cover_image.attach(io: File.open(Rails.root.join("spec/fixtures/files/cover.svg")), filename: "cover.svg", content_type: "image/svg+xml")
      active_storage_post.attachments.attach(io: File.open(Rails.root.join("spec/fixtures/files/notes.txt")), filename: "notes.txt", content_type: "text/plain")
    end

    it "updates the title and attachments" do
      patch "/active_storage_posts/#{active_storage_post.id}", params: {
        active_storage_post: {
          title: "Updated title",
          cover_image: fixture_file_upload(Rails.root.join("spec/fixtures/files/cover.svg"), "image/svg+xml"),
          attachments: [ fixture_file_upload(Rails.root.join("spec/fixtures/files/checklist.txt"), "text/plain") ]
        }
      }

      active_storage_post.reload

      expect(active_storage_post.title).to eq("Updated title")
      expect(active_storage_post.cover_image).to be_attached
      expect(active_storage_post.attachments.map { |attachment| attachment.filename.to_s }).to eq([ "checklist.txt" ])
    end

    it "returns validation errors" do
      old_title = active_storage_post.title

      patch "/active_storage_posts/#{active_storage_post.id}", params: {
        active_storage_post: {
          title: "",
          attachments: [ fixture_file_upload(Rails.root.join("spec/fixtures/files/checklist.txt"), "text/plain") ]
        }
      }

      expect(active_storage_post.reload.title).to eq(old_title)
      expect(flash[:alert]).to match("Title can't be blank")
    end
  end

  describe "DELETE destroy" do
    it "deletes the post" do
      active_storage_post

      expect { delete "/active_storage_posts/#{active_storage_post.id}" }.to change(ActiveStoragePost, :count).by(-1)
    end
  end
end
