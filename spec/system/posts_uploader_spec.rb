# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Posts uploader", type: :system do
  it "renders the uploader components" do
    visit "/posts/new"

    expect(page).to have_css("uc-file-uploader-regular", count: 2)
    expect(page).to have_css("uc-form-input", count: 2)
    expect(page).to have_css("uc-config", count: 2)
    expect(page).to have_css("uc-upload-ctx-provider", count: 2)
  end

  it "preloads uploader values on edit" do
    post_record = create(:post)

    visit "/posts/#{post_record.id}/edit"

    expect(page).to have_css(%(uc-form-input[name="post[logo]"][value="#{post_record.logo}"]))
    expect(page).to have_css(%(uc-form-input[name="post[attachments]"][value="#{post_record.attachments}"]))
  end
end
