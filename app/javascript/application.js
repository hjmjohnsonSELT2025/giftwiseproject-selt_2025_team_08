import "@hotwired/turbo-rails"
import "@hotwired/stimulus-loading"
import "./discussion_polling.js"

import { Application } from "@hotwired/stimulus"
import EventFormController from "./controllers/event_form_controller.js"

const application = Application.start()
application.register("event-form", EventFormController)
