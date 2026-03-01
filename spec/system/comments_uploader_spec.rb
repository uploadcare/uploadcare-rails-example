# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Comments uploader", type: :system do
  it "renders uploader components", :js do
    visit "/comments/new"

    expect(page).to have_css("uc-file-uploader-regular", count: 2)
    expect(page).to have_css("uc-form-input", count: 2)
    expect(page).to have_button("Upload files", count: 2)
  end
end
