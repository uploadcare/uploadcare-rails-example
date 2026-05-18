# frozen_string_literal: true

require "rails_helper"

RSpec.describe PostsController, type: :request do
  let(:post_object) { create :post }

  describe "GET index" do
    it "returns a 200" do
      post_object

      get "/posts"

      expect(response.body).to match(post_object.title)
    end
  end

  describe "GET new" do
    it "renders a template" do
      get "/posts/new"

      expect(response).to render_template(:new)
    end

    it "renders uploader elements" do
      get "/posts/new"

      expect(response.body).to include("uc-file-uploader-regular")
      expect(response.body).to include("uc-form-input")
      expect(response.body).to include("post[logo]")
      expect(response.body).to include("post[attachments]")
      expect(response.body).to include('multiple="true"')
      expect(response.body).to include('group-output="true"')
    end
  end

  describe "GET edit" do
    it "renders a template" do
      get "/posts/#{post_object.id}/edit"

      expect(response).to render_template(:edit)
    end

    it "preloads uploader values" do
      get "/posts/#{post_object.id}/edit"

      expect(response.body).to include(%(value="#{post_object.logo}"))
      expect(response.body).to include(%(value="#{post_object.attachments}"))
    end
  end

  describe "GET show" do
    it "returns a 200" do
      allow_any_instance_of(Uploadcare::Rails::AttachedFile).to receive(:load).and_return(
        Uploadcare::Rails::AttachedFile.new(
          {
            "uuid" => "logo-uuid",
            "cdn_url" => "https://ucarecdn.com/logo-uuid/",
            "original_filename" => "logo.png",
            "mime_type" => "image/png"
          }
        )
      )
      allow_any_instance_of(PostsController).to receive(:load_group_files).and_return([])

      get "/posts/#{post_object.id}"

      expect(response).to render_template(:show)
    end

    it "returns an error when attachment loading fails" do
      allow_any_instance_of(PostsController).to receive(:load_group_files).and_raise(Uploadcare::Exception::RequestError, "")

      get "/posts/#{post_object.id}"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "POST create" do
    it "creates a post" do
      expect do
        post "/posts", params: {
          post: { title: "Title", logo: "https://logourl.com", attachments: "https://attachmentsurl.com" }
        }
      end.to change(Post, :count).by(1)
    end

    it "returns post errors" do
      expect do
        post "/posts", params: {
          post: { title: "", logo: "https://logourl.com", attachments: "https://attachmentsurl.com" }
        }
      end.not_to change(Post, :count)

      expect(flash[:alert]).to match("Title can't be blank")
    end
  end

  describe "PATCH update" do
    it "updates a post" do
      expect do
        patch "/posts/#{post_object.id}", params: {
          post: {
            title: post_object.title.reverse,
            logo: "#{post_object.logo}/new",
            attachments: "#{post_object.attachments}/new"
          }
        }
      end.to change { post_object.reload.title }
    end

    it "returns post errors" do
      old_attributes = post_object.attributes

      patch "/posts/#{post_object.id}", params: {
        post: { title: "", logo: "#{post_object.logo}/new", attachments: "#{post_object.attachments}/new" }
      }

      expect(post_object.reload.attributes).to eq(old_attributes)
      expect(flash[:alert]).to match("Title can't be blank")
    end
  end

  describe "DELETE destroy" do
    it "deletes a post" do
      post_object

      expect { delete "/posts/#{post_object.id}" }.to change(Post, :count).by(-1)
    end
  end
end
