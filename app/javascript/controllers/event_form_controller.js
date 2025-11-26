import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["attendeeSearch", "attendeeResults", "attendeesList", "contactSearch", "contactResults", "recipientsList", "noAttendeesMsg", "noRecipientsMsg"]
  
  connect() {
    this.selectedAttendees = new Set()
    this.selectedContacts = new Set()
    this.existingRecipientIds = new Set()
    this.existingRecipientNames = new Map()
    this.eventId = this.element.dataset.eventId || null
    
    this.initializeExistingItems()
  }

  initializeExistingItems() {
    this.element.querySelectorAll('.attendee-item').forEach(li => {
      const attendeeId = parseInt(li.getAttribute('data-attendee-id'))
      if (!isNaN(attendeeId)) {
        this.selectedAttendees.add(attendeeId)
      }
    })

    this.element.querySelectorAll('.recipient-item').forEach(li => {
      const recipientId = parseInt(li.getAttribute('data-recipient-id'))
      if (!isNaN(recipientId)) {
        this.existingRecipientIds.add(recipientId)
        const name = li.textContent.trim().replace('Remove', '').trim()
        this.existingRecipientNames.set(name, recipientId)
        this.selectedContacts.add(`recipient-${recipientId}`)
      }
    })
  }

  async searchAttendees(event) {
    await this.performSearch(
      event.target.value,
      this.attendeeResultsTarget,
      'attendee',
      this.selectedAttendees,
      this.handleAttendeeToggle.bind(this)
    )
  }

  async searchContacts(event) {
    await this.performSearch(
      event.target.value,
      this.contactResultsTarget,
      'recipient',
      this.selectedContacts,
      this.handleContactToggle.bind(this),
      this.existingRecipientNames
    )
  }

  async performSearch(query, resultsContainer, type, selectedSet, toggleHandler, existingNames = null) {
    query = query.trim()
    if (query.length < 2) {
      resultsContainer.innerHTML = ''
      return
    }

    try {
      const response = await fetch(`/contacts/search.json?q=${encodeURIComponent(query)}`)
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      const data = await response.json()

      resultsContainer.innerHTML = ''

      if (data.contacts && data.contacts.length > 0) {
        data.contacts.forEach(contact => {
          const isSelected = selectedSet.has(contact.id)
          const isAlreadyRecipient = existingNames && existingNames.has(`${contact.first_name} ${contact.last_name}`)
          const disabled = isAlreadyRecipient || isSelected

          const div = document.createElement('div')
          div.className = 'search-result-item'
          
          const buttonText = type === 'recipient' && isAlreadyRecipient 
            ? 'Already a Recipient' 
            : (isSelected ? `Added as ${type === 'attendee' ? 'Attendee' : 'Recipient'}` : `Add as ${type === 'attendee' ? 'Attendee' : 'Recipient'}`)

          div.innerHTML = `
            <div class="contact-info">
              <strong>${contact.first_name} ${contact.last_name}</strong>
              ${contact.occupation ? `<br><small>Occupation: ${contact.occupation}</small>` : ''}
            </div>
            <button 
              type="button" 
              class="toggle-contact" 
              data-contact-id="${contact.id}"
              data-first-name="${contact.first_name}"
              data-last-name="${contact.last_name}"
              ${disabled ? 'disabled' : ''}
            >
              ${buttonText}
            </button>
          `

          const btn = div.querySelector('.toggle-contact')
          if (!disabled) {
            btn.addEventListener('click', (e) => {
              e.preventDefault()
              toggleHandler(contact, btn)
            })
          }

          resultsContainer.appendChild(div)
        })
      } else {
        resultsContainer.innerHTML = '<p>No contacts found.</p>'
      }
    } catch (error) {
      console.error('Search error:', error)
      resultsContainer.innerHTML = '<p>Error searching contacts.</p>'
    }
  }

  handleAttendeeToggle(contact, btn) {
    this.selectedAttendees.add(contact.id)
    btn.disabled = true
    btn.textContent = 'Added as Attendee'

    if (this.eventId) {
      this.createAttendee(contact, btn)
    } else {
      this.addAttendeeToList(contact)
    }
  }

  handleContactToggle(contact, btn) {
    this.selectedContacts.add(contact.id)
    btn.disabled = true
    btn.textContent = 'Added as Recipient'

    if (this.eventId) {
      this.createRecipient(contact, btn)
    } else {
      this.addRecipientToList(contact)
    }
  }

  async createAttendee(contact, btn) {
    try {
      const response = await fetch(`/events/${this.eventId}/attendees`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          event_attendee: { user_id: contact.id }
        })
      })

      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      const data = await response.json()

      if (data.id) {
        contact.attendee_record_id = data.id
        this.addAttendeeToList(contact)
      }
    } catch (error) {
      console.error('Error creating attendee:', error)
      this.selectedAttendees.delete(contact.id)
      btn.disabled = false
      btn.textContent = 'Add as Attendee'
    }
  }

  async createRecipient(contact, btn) {
    try {
      const response = await fetch(`/events/${this.eventId}/recipients`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
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
        })
      })

      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      const data = await response.json()

      if (data.id) {
        contact.recipient_id = data.id
        this.addRecipientToList(contact)
      }
    } catch (error) {
      console.error('Error creating recipient:', error)
      this.selectedContacts.delete(contact.id)
      btn.disabled = false
      btn.textContent = 'Add as Recipient'
    }
  }

  addAttendeeToList(contact) {
    if (this.noAttendeesMsgTarget && this.noAttendeesMsgTarget.parentNode) {
      this.noAttendeesMsgTarget.remove()
    }

    let ul = this.attendeesListTarget
    if (!ul || ul.children.length === 0) {
      ul = document.createElement('ul')
      ul.id = 'attendees-list'
      ul.className = 'attendees-list'
      this.element.querySelector('#attendees-section').insertBefore(ul, this.element.querySelector('.attendee-search-section'))
    }

    const existingLi = ul.querySelector(`li[data-attendee-id="${contact.id}"]`)
    if (!existingLi) {
      const li = document.createElement('li')
      li.className = 'attendee-item'
      li.setAttribute('data-attendee-id', contact.id)
      li.innerHTML = `
        ${contact.first_name} ${contact.last_name}
        <button type="button" class="remove-attendee" data-attendee-id="${contact.id}">Remove</button>
      `

      const removeBtn = li.querySelector('.remove-attendee')
      removeBtn.addEventListener('click', (e) => this.removeAttendee(e, contact, li, ul))

      ul.appendChild(li)
    }
  }

  addRecipientToList(contact) {
    if (this.noRecipientsMsgTarget && this.noRecipientsMsgTarget.parentNode) {
      this.noRecipientsMsgTarget.remove()
    }

    let ul = this.recipientsListTarget
    if (!ul || ul.children.length === 0) {
      ul = document.createElement('ul')
      ul.id = 'recipients-list'
      ul.className = 'recipients-list'
      this.element.querySelector('#recipients-section').insertBefore(ul, this.element.querySelector('.contact-search-section'))
    }

    const recipientId = contact.recipient_id
    const existingLi = ul.querySelector(`li[data-recipient-id="${recipientId}"]`)
    if (!existingLi) {
      const li = document.createElement('li')
      li.className = 'recipient-item'
      li.setAttribute('data-contact-id', contact.id)
      li.setAttribute('data-recipient-id', recipientId || '')
      const name = `${contact.first_name} ${contact.last_name}`
      li.innerHTML = `
        ${name}
        <button type="button" class="remove-recipient" data-recipient-id="${recipientId || ''}">Remove</button>
      `

      const removeBtn = li.querySelector('.remove-recipient')
      removeBtn.addEventListener('click', (e) => this.removeRecipient(e, recipientId, contact.id, name, li, ul))

      this.existingRecipientIds.add(recipientId)
      this.existingRecipientNames.set(name, recipientId)

      ul.appendChild(li)
    }
  }

  removeAttendee(e, contact, li, ul) {
    e.preventDefault()
    this.selectedAttendees.delete(contact.id)
    li.remove()
    this.updateAttendeesDisplay(ul)

    if (this.eventId && contact.attendee_record_id) {
      fetch(`/events/${this.eventId}/attendees/${contact.attendee_record_id}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      }).catch(error => console.error('Delete error:', error))
    }

    const searchBtn = document.querySelector(`button[data-contact-id="${contact.id}"].toggle-contact`)
    if (searchBtn) {
      searchBtn.disabled = false
      searchBtn.textContent = 'Add as Attendee'
    }
  }

  removeRecipient(e, recipientId, contactId, name, li, ul) {
    e.preventDefault()
    this.selectedContacts.delete(contactId)
    this.existingRecipientIds.delete(recipientId)
    this.existingRecipientNames.delete(name)
    li.remove()
    this.updateRecipientsDisplay(ul)

    if (this.eventId && recipientId) {
      fetch(`/recipients/${recipientId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      }).catch(error => console.error('Delete error:', error))
    }

    const searchBtn = document.querySelector(`button[data-contact-id="${contactId}"].toggle-contact`)
    if (searchBtn) {
      searchBtn.disabled = false
      searchBtn.textContent = 'Add as Recipient'
    }
  }

  updateAttendeesDisplay(ul) {
    if (!ul || ul.querySelectorAll('li').length === 0) {
      if (ul) ul.remove()
      if (!this.noAttendeesMsgTarget) {
        const p = document.createElement('p')
        p.id = 'no-attendees'
        p.textContent = 'No attendees added yet.'
        this.element.querySelector('#attendees-section').insertBefore(p, this.element.querySelector('.attendee-search-section'))
      }
    }
  }

  updateRecipientsDisplay(ul) {
    if (!ul || ul.querySelectorAll('li').length === 0) {
      if (ul) ul.remove()
      if (!this.noRecipientsMsgTarget) {
        const p = document.createElement('p')
        p.id = 'no-recipients'
        p.textContent = 'No recipients added yet.'
        this.element.querySelector('#recipients-section').insertBefore(p, this.element.querySelector('.contact-search-section'))
      }
    }
  }
}
