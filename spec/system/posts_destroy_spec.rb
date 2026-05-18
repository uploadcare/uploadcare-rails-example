# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Posts destroy", type: :system do
  it "deletes a post via the button_to control on the show page" do
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

    post_record = create(:post)

    visit post_path(post_record)

    expect do
      first("form[action=\"#{post_path(post_record)}\"] button", text: "Delete").click
    end.to change(Post, :count).by(-1)

    expect(page).to have_current_path(posts_path)
  end
end
