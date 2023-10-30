import { Application } from "@hotwired/stimulus"

const application = Application.start()
window.Stimulus   = application

export { application }

// Import things
import {Dropdown } from "tailwindcss-stimulus-components"
application.register('dropdown', Dropdown)
