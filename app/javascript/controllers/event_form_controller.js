import { Controller } from "@hotwired/stimulus"

export default class EventFormController extends Controller {
  static values = {
    eventId: Number
  }

  static targets = ["participantSearch", "participantsList"]

  connect() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]').content
    this.tempParticipants = {}
    this.searchTimeout = null
    
    const form = this.element.closest('form')
    if (form) {
      form.addEventListener('submit', (e) => this.handleFormSubmit(e))
    }
  }

  searchParticipants() {
    const query = this.participantSearchTarget.value.trim()
    if (!query) {
      document.querySelector("#participant-search-results").innerHTML = ''
      return
    }

    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    try {
      const url = `/contacts/search.json?q=${encodeURIComponent(query)}`
      
      const response = await fetch(url)
      
      if (!response.ok) {
        throw new Error(`Search failed with status ${response.status}`)
      }

      const data = await response.json()
      this.displayResults(data.contacts || [])
    } catch (error) {
      console.error("Search error:", error)
      const resultsDiv = document.querySelector("#participant-search-results")
      resultsDiv.innerHTML = `<p class='text-danger'>Error: ${error.message}</p>`
    }
  }

  displayResults(contacts) {
    const resultsDiv = document.querySelector("#participant-search-results")
    const addedAttendeeUserIds = Array.from(this.participantsListTarget.querySelectorAll('[data-participant-type="attendee"]')).map(li => {
      return li.getAttribute('data-user-id')
    }).filter(id => id)
    
    const filteredContacts = contacts.filter(contact => {
      const isAddedAsAttendee = addedAttendeeUserIds.includes(String(contact.id))
      const isAddedAsRecipient = Array.from(
        this.participantsListTarget.querySelectorAll('[data-participant-type="recipient"]')
      ).some(li => {
        const recipientNameSpan = li.querySelector('span')
        const recipientName = recipientNameSpan ? recipientNameSpan.textContent.trim() : ''
        const contactFullName = `${contact.first_name} ${contact.last_name}`.trim()
        return recipientName === contactFullName
      })
      
      const isAdded = isAddedAsAttendee || isAddedAsRecipient
      return !isAdded
    })
    
    if (!filteredContacts || filteredContacts.length === 0) {
      resultsDiv.innerHTML = "<p class='text-white'>No contacts found.</p>"
      return
    }

    resultsDiv.innerHTML = ""
    filteredContacts.forEach(contact => {
      const displayName = `${contact.first_name} ${contact.last_name}`
      
      const div = document.createElement("div")
      div.className = "d-flex justify-content-between align-items-center mb-2 p-2"
      div.style.backgroundColor = "#2a2a2a"
      div.style.borderRadius = "4px"

      const nameDiv = document.createElement("div")
      const span = document.createElement("span")
      span.textContent = displayName
      span.style.color = "#e5e5e5"
      nameDiv.appendChild(span)
      
      if (contact.occupation) {
        const small = document.createElement("br")
        const smallText = document.createElement("small")
        smallText.textContent = contact.occupation
        smallText.style.color = "#999"
        nameDiv.appendChild(small)
        nameDiv.appendChild(smallText)
      }

      const buttonsDiv = document.createElement("div")
      
      const recipientBtn = document.createElement("button")
      recipientBtn.type = "button"
      recipientBtn.className = "btn btn-sm btn-success me-2"
      recipientBtn.textContent = "Add as Recipient"
      recipientBtn.dataset.contactId = contact.id
      recipientBtn.addEventListener("click", (e) => {
        e.preventDefault()
        this.addAsRecipient(contact)
      })

      const contributorBtn = document.createElement("button")
      contributorBtn.type = "button"
      contributorBtn.className = "btn btn-sm btn-primary"
      contributorBtn.textContent = "Add as Contributor"
      contributorBtn.dataset.contactId = contact.id
      contributorBtn.addEventListener("click", (e) => {
        e.preventDefault()
        this.addAsContributor(contact)
      })

      buttonsDiv.appendChild(recipientBtn)
      buttonsDiv.appendChild(contributorBtn)

      div.appendChild(nameDiv)
      div.appendChild(buttonsDiv)
      resultsDiv.appendChild(div)
    })
  }

  addAsRecipient(contact) {
    this.addParticipant(contact, 'recipient', 'bg-success', 'Recipient')
    this.clearSearch()
  }

  addAsContributor(contact) {
    this.addParticipant(contact, 'attendee', 'bg-primary', 'Contributor')
    this.clearSearch()
  }

  addParticipant(contact, participantType, badgeClass, roleLabel) {
    const existingParticipant = this.participantsListTarget.querySelector(`[data-participant-id="${contact.id}"]`)
    if (existingParticipant) {
      alert(`${contact.first_name} ${contact.last_name} is already added to this event.`)
      return
    }

    const participantId = contact.id
    const displayName = `${contact.first_name} ${contact.last_name}`

    if (this.eventIdValue) {
      this.addParticipantToServer(contact, participantType, participantId, displayName, badgeClass, roleLabel)
    } else {
      this.addParticipantToUI(participantId, displayName, participantType, badgeClass, roleLabel)
      const tempId = "temp-" + participantId + "-" + participantType
      this.tempParticipants[tempId] = contact
    }
  }

  async addParticipantToServer(contact, participantType, participantId, displayName, badgeClass, roleLabel) {
    try {
      const controller = new AbortController()
      const timeout = setTimeout(() => controller.abort(), 10000)

      if (participantType === 'attendee') {
        const response = await fetch(`/events/${this.eventIdValue}/attendees`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": this.csrfToken
          },
          body: JSON.stringify({ event_attendee: { user_id: participantId } }),
          signal: controller.signal
        })
        clearTimeout(timeout)

        if (response.ok) {
          const result = await response.json()
          this.addParticipantToUI(result.id, displayName, participantType, badgeClass, roleLabel)
        } else {
          console.error("Failed to add attendee:", response.status)
        }
      } else {
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
          this.addParticipantToUI(result.id, displayName, participantType, badgeClass, roleLabel)
        } else {
          console.error("Failed to add recipient:", response.status)
        }
      }
    } catch (error) {
      console.error("Error adding participant:", error)
    }
  }

  addParticipantToUI(participantId, displayName, participantType, badgeClass, roleLabel) {
    const li = document.createElement('li')
    li.dataset.participantId = participantId
    li.dataset.participantType = participantType
    li.className = 'd-flex justify-content-between align-items-center mb-2 p-2'
    li.style.backgroundColor = '#2a2a2a'
    li.style.borderRadius = '4px'

    const nameDiv = document.createElement("div")
    const span = document.createElement("span")
    span.textContent = displayName
    span.style.color = '#e5e5e5'
    nameDiv.appendChild(span)

    const badge = document.createElement("span")
    badge.className = `badge ${badgeClass}`
    badge.textContent = roleLabel
    badge.style.marginLeft = "0.5rem"
    nameDiv.appendChild(badge)

    const button = document.createElement("button")
    button.type = "button"
    button.className = "btn btn-sm btn-danger"
    button.textContent = "Remove"
    button.addEventListener('click', () => this.removeParticipant(li, participantId, participantType))

    li.appendChild(nameDiv)
    li.appendChild(button)
    this.participantsListTarget.appendChild(li)
    this.addHiddenInput(participantId, participantType)

    const noParticipantsMsg = document.querySelector('#no-participants')
    if (noParticipantsMsg) {
      noParticipantsMsg.style.display = 'none'
    }

  }

  removeParticipant(li, participantId, participantType) {
    if (this.eventIdValue && !String(participantId).startsWith("temp-")) {
      this.removeParticipantFromServer(participantId, participantType, li)
    } else {
      li.remove()
      this.removeHiddenInput(participantId, participantType)
      this.updateParticipantsVisibility()
      delete this.tempParticipants[`temp-${participantId}-${participantType}`]
    }
  }

  async removeParticipantFromServer(participantId, participantType, li) {
    try {
      const controller = new AbortController()
      const timeout = setTimeout(() => controller.abort(), 10000)

      let url
      if (participantType === 'attendee') {
        url = `/events/${this.eventIdValue}/attendees/${participantId}`
      } else {
        url = `/recipients/${participantId}`
      }

      const response = await fetch(url, {
        method: "DELETE",
        headers: { "X-CSRF-Token": this.csrfToken },
        signal: controller.signal
      })
      clearTimeout(timeout)

      if (response.ok) {
        li.remove()
        this.removeHiddenInput(participantId, participantType)
        this.updateParticipantsVisibility()
      } else {
        console.error("Failed to remove participant:", response.status)
      }
    } catch (error) {
      console.error("Error removing participant:", error)
    }
  }

  addHiddenInput(participantId, participantType) {
    const fieldName = participantType === 'recipient' ? 'event[recipient_ids][]' : 'event[attendee_ids][]'
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = fieldName
    input.value = participantId
    const form = document.querySelector('form')
    if (form) {
      form.appendChild(input)
    }
  }

  removeHiddenInput(participantId, participantType) {
    const fieldName = participantType === 'recipient' ? 'event[recipient_ids][]' : 'event[attendee_ids][]'
    const input = document.querySelector(`input[name="${fieldName}"][value="${participantId}"]`)
    if (input) {
      input.remove()
    }
  }

  updateParticipantsVisibility() {
    const noParticipantsMsg = document.querySelector('#no-participants')
    if (noParticipantsMsg) {
      const hasParticipants = this.participantsListTarget.querySelectorAll('li').length > 0
      noParticipantsMsg.style.display = hasParticipants ? 'none' : 'block'
    }
  }

  clearSearch() {
    this.participantSearchTarget.value = ''
    document.querySelector('#participant-search-results').innerHTML = ''
  }

  handleFormSubmit(e) {
    if (this.eventIdValue) {
      return
    }

    const hiddenFieldsContainer = document.querySelector('#participants-hidden-fields')
    hiddenFieldsContainer.innerHTML = ''

    const attendeeElements = this.participantsListTarget.querySelectorAll('[data-participant-type="attendee"]')
    attendeeElements.forEach(li => {
      const userId = li.getAttribute('data-user-id')
      if (userId) {
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = 'event[attendee_ids][]'
        input.value = userId
        hiddenFieldsContainer.appendChild(input)
      }
    })

    const recipientElements = this.participantsListTarget.querySelectorAll('[data-participant-type="recipient"]')
    recipientElements.forEach(li => {
      const nameSpan = li.querySelector('span')
      const fullName = nameSpan ? nameSpan.textContent.trim() : ''
      const [firstName, ...lastNameParts] = fullName.split(' ')
      const lastName = lastNameParts.join(' ')
      
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'event[recipient_data][]'
      input.value = JSON.stringify({
        first_name: firstName,
        last_name: lastName
      })
      hiddenFieldsContainer.appendChild(input)
    })
  }
}
