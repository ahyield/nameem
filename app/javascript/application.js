// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from "@hotwired/turbo-rails"
import "controllers"
import "@fortawesome/fontawesome-free"
import { DARK_QUERY, followSystemTheme } from "lib/theme"

import { turboConfirm } from "lib/confirm_dialog"

followSystemTheme(document.documentElement, window.matchMedia(DARK_QUERY))
Turbo.config.forms.confirm = turboConfirm

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import "trix"
import "@rails/actiontext"
