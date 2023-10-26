import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = true
window.Stimulus   = application

export { application }

// Import things
import {Dropdown } from "tailwindcss-stimulus-components"
application.register('dropdown', Dropdown)
