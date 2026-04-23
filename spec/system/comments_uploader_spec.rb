# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Comments uploader", type: :system do
  it "renders uploader components" do
    visit "/comments/new"

    expect(page).to have_css("uc-file-uploader-regular", count: 2)
    expect(page).to have_css("uc-form-input", count: 2)
    expect(page).to have_css("uc-config", count: 2)
    expect(page).to have_css("uc-upload-ctx-provider", count: 2)
  end

  it "preloads uploader values on edit" do
    comment_record = create(:comment)

    visit "/comments/#{comment_record.id}/edit"

    expect(page).to have_css(%(uc-form-input[name="comment[image]"][value="#{comment_record.image}"]))
    expect(page).to have_css(%(uc-form-input[name="comment[attachments]"][value="#{comment_record.attachments}"]))
  end
end
