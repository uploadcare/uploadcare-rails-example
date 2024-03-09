// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "@hotwired/turbo-rails"
import Rails from "@rails/ujs"
import {Turbo} from "@hotwired/turbo-rails"

Turbo.start()
Rails.start()
