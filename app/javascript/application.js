// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@fortawesome/fontawesome-free"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import "trix"
import "@rails/actiontext"
