# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Posts uploader", type: :system do
  it "renders the uploader components", :js do
    visit "/posts/new"

    expect(page).to have_css("uc-file-uploader-regular", count: 2)
    expect(page).to have_css("uc-form-input", count: 2)
    expect(page).to have_button("Upload files", count: 2)
  end
end
