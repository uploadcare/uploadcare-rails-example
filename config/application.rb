require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module UploadcareRailsExample
  class Application < Rails::Application
    initializer "uploadcare_rails.ignore_hyphenated_entrypoint", before: :set_autoload_paths do
      spec = Bundler.load.specs.find { |gem_spec| gem_spec.name == "uploadcare-rails" }
      next unless spec

      entrypoint = Pathname(spec.full_gem_path).join("lib/uploadcare-rails.rb")
      form_builder = Pathname(spec.full_gem_path).join("lib/uploadcare/rails/action_view/form_builder.rb")
      Rails.autoloaders.main.ignore(entrypoint)
      Rails.autoloaders.once.ignore(entrypoint)
      Rails.autoloaders.main.ignore(form_builder)
      Rails.autoloaders.once.ignore(form_builder)
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.action_view.form_with_generates_remote_forms = false
  end
end
