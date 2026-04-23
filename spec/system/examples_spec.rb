# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Examples", type: :system do
  it "shows grouped feature examples on overview page" do
    visit "/examples"

    expect(page).to have_text("Examples")
    expect(page).to have_text("Core API operations")
    expect(page).to have_text("Conversions and add-ons")
    expect(page).to have_text("Uploader field helper APIs")
  end

  it "shows uploader helper example page" do
    visit "/examples/uploader_fields"

    expect(page).to have_text("Uploader Helper Examples")
    expect(page).to have_text("Model-backed helpers")
    expect(page).to have_text("Standalone tag helpers")
  end
end
