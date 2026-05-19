# frozen_string_literal: true

require "capybara-playwright-driver"
require "playwright"

PLAYWRIGHT_CLI_EXECUTABLE_PATH = ENV.fetch(
  "PLAYWRIGHT_CLI_EXECUTABLE_PATH",
  "npx playwright@#{Playwright::COMPATIBLE_PLAYWRIGHT_VERSION}"
)

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium,
    headless: ENV.fetch("PLAYWRIGHT_HEADLESS", "true") != "false",
    playwright_cli_executable_path: PLAYWRIGHT_CLI_EXECUTABLE_PATH
  )
end

Capybara.save_path = Rails.root.join("tmp/capybara").to_s
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.before(:each, type: :system) do |example|
    driven_by(example.metadata[:playwright] ? :playwright : :rack_test)
  end
end
