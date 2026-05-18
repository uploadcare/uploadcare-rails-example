# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Active Storage posts", type: :system do
  it "creates a post with one and many attachments" do
    visit "/active_storage_posts/new"

    fill_in "Title", with: "Browser-created Active Storage post"
    attach_file "active_storage_post_cover_image", Rails.root.join("spec/fixtures/files/cover.svg")
    attach_file "active_storage_post_attachments", [
      Rails.root.join("spec/fixtures/files/notes.txt"),
      Rails.root.join("spec/fixtures/files/checklist.txt")
    ]

    click_button "Save"

    expect(page).to have_content('Active Storage post "Browser-created Active Storage post"')
    expect(page).to have_link("cover.svg")
    expect(page).to have_link("notes.txt")
    expect(page).to have_link("checklist.txt")
    expect(page).to have_content("test")
  end
end
