import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    eventId: Number
  }

  static targets = ["attendeeSearch", "recipientSearch", "attendeesList", "recipientsList"]

  connect() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]').content
    this.tempAttendees = {}
    this.tempRecipients = {}
    
    this.attendeesListTarget.addEventListener("click", (e) => this.handleAttendeeRemove(e))
    this.recipientsListTarget.addEventListener("click", (e) => this.handleRecipientRemove(e))
  }

  handleAttendeeRemove(event) {
    const btn = event.target.closest(".btn-small")
    if (!btn) return
    
    event.preventDefault()
    const li = event.target.closest("li")
    const attendeeId = li.getAttribute("data-attendee-id")
    this.removeAttendee(attendeeId, li)
  }

  handleRecipientRemove(event) {
    const btn = event.target.closest(".btn-small")
    if (!btn) return
    
    event.preventDefault()
    const li = event.target.closest("li")
    const recipientId = li.getAttribute("data-recipient-id")
    this.removeRecipient(recipientId, li)
  }

  async searchAttendees() {
    await this.searchContacts('attendee')
  }

  async searchRecipients() {
    await this.searchContacts('recipient')
  }

  async searchContacts(type) {
    const targetName = `${type}SearchTarget`
    const query = this[targetName].value.trim()
    if (!query) return

    try {
      const response = await fetch(`/contacts/search.json?q=${encodeURIComponent(query)}`)
      if (!response.ok) throw new Error("Search failed")

      const data = await response.json()
      this.displayResults(data.contacts || [], type)
    } catch (error) {
      console.error("Error:", error)
    }
  }

  displayResults(contacts, type) {
    const resultsDivId = type === 'attendee' ? "#attendee-search-results" : "#contact-search-results"
    const resultsDiv = document.querySelector(resultsDivId)
    resultsDiv.innerHTML = ""

    if (contacts.length === 0) {
      resultsDiv.innerHTML = "<p>No contacts found</p>"
      return
    }

    contacts.forEach((contact) => {
      const div = document.createElement("div")
      const span = document.createElement("span")
      span.textContent = `${contact.first_name} ${contact.last_name}`
      
      const button = document.createElement("button")
      button.type = "button"
      button.className = "btn-add"
      button.textContent = type === 'attendee' ? "Add as Attendee" : "Add as Recipient"
      button.addEventListener("click", (e) => {
        e.preventDefault()
        if (type === 'attendee') {
          this.addAttendee(contact)
        } else {
          this.addRecipient(contact)
        }
      })
      
      div.appendChild(span)
      div.appendChild(button)
      resultsDiv.appendChild(div)
    })
  }

  async addAttendee(contact) {
    if (this.eventIdValue) {
      try {
        const controller = new AbortController()
        const timeout = setTimeout(() => controller.abort(), 10000)
        
        const response = await fetch(`/events/${this.eventIdValue}/attendees`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": this.csrfToken
          },
          body: JSON.stringify({ event_attendee: { user_id: contact.id } }),
          signal: controller.signal
        })
        clearTimeout(timeout)
        
        if (response.ok) {
          const result = await response.json()
          this.addToAttendeesList(contact, result.id)
        }
      } catch (error) {
        console.error("Error adding attendee:", error)
      }
    } else {
      const tempId = "temp-" + Math.random().toString(36).substr(2, 9)
      this.tempAttendees[tempId] = contact
      this.addToAttendeesList(contact, tempId)
    }
  }

  async addRecipient(contact) {
    if (this.eventIdValue) {
      try {
        const controller = new AbortController()
        const timeout = setTimeout(() => controller.abort(), 10000)
        
        const response = await fetch(`/events/${this.eventIdValue}/recipients`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": this.csrfToken
          },
          body: JSON.stringify({
            recipient: {
              first_name: contact.first_name,
              last_name: contact.last_name,
              occupation: contact.occupation || null,
              hobbies: contact.hobbies || null,
              likes: contact.likes || null,
              dislikes: contact.dislikes || null
            }
          }),
          signal: controller.signal
        })
        clearTimeout(timeout)
        
        if (response.ok) {
          const result = await response.json()
          this.addToRecipientsList(contact, result.id)
        }
      } catch (error) {
        console.error("Error adding recipient:", error)
      }
    } else {
      const tempId = "temp-" + Math.random().toString(36).substr(2, 9)
      this.tempRecipients[tempId] = contact
      this.addToRecipientsList(contact, tempId)
    }
  }

  addToAttendeesList(contact, id) {
    const li = document.createElement("li")
    li.setAttribute("data-attendee-id", id)
    
    const nameSpan = document.createElement("span")
    nameSpan.textContent = `${contact.first_name} ${contact.last_name}`
    
    const button = document.createElement("button")
    button.type = "button"
    button.className = "btn-small"
    button.textContent = "Remove"
    
    li.appendChild(nameSpan)
    li.appendChild(button)
    this.attendeesListTarget.appendChild(li)
    this.updateAttendeeVisibility()
    document.querySelector("#attendee-search-results").innerHTML = ""
  }

  addToRecipientsList(contact, id) {
    const li = document.createElement("li")
    li.setAttribute("data-recipient-id", id)
    
    const nameSpan = document.createElement("span")
    nameSpan.textContent = `${contact.first_name} ${contact.last_name}`
    
    const button = document.createElement("button")
    button.type = "button"
    button.className = "btn-small"
    button.textContent = "Remove"
    
    li.appendChild(nameSpan)
    li.appendChild(button)
    this.recipientsListTarget.appendChild(li)
    this.updateRecipientVisibility()
    document.querySelector("#contact-search-results").innerHTML = ""
  }

  async removeAttendee(attendeeId, li) {
    if (this.eventIdValue && !attendeeId.startsWith("temp-")) {
      try {
        const response = await fetch(`/events/${this.eventIdValue}/attendees/${attendeeId}`, {
          method: "DELETE",
          headers: { "X-CSRF-Token": this.csrfToken }
        })
        if (response.ok) {
          li.remove()
          this.updateAttendeeVisibility()
        }
      } catch (error) {
        console.error("Error:", error)
      }
    } else {
      delete this.tempAttendees[attendeeId]
      li.remove()
      this.updateAttendeeVisibility()
    }
  }

  async removeRecipient(recipientId, li) {
    if (this.eventIdValue && !recipientId.startsWith("temp-")) {
      try {
        const response = await fetch(`/recipients/${recipientId}`, {
          method: "DELETE",
          headers: { "X-CSRF-Token": this.csrfToken }
        })
        if (response.ok) {
          li.remove()
          this.updateRecipientVisibility()
        }
      } catch (error) {
        console.error("Error:", error)
      }
    } else {
      delete this.tempRecipients[recipientId]
      li.remove()
      this.updateRecipientVisibility()
    }
  }

  updateAttendeeVisibility() {
    const noAttendees = document.querySelector("#no-attendees")
    if (noAttendees) {
      noAttendees.style.display = this.attendeesListTarget.children.length === 0 ? "block" : "none"
    }
  }

  updateRecipientVisibility() {
    const noRecipients = document.querySelector("#no-recipients")
    if (noRecipients) {
      noRecipients.style.display = this.recipientsListTarget.children.length === 0 ? "block" : "none"
    }
  }
}
