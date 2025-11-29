function startDiscussionPolling() {
  const container = document.querySelector('[data-controller="discussion"]')
  if (!container) return

  if (container.dataset.pollingInitialized === 'true') {
    return
  }
  container.dataset.pollingInitialized = 'true'

  const eventId = container.getAttribute('data-discussion-event-id-value')
  const threadType = container.getAttribute('data-discussion-thread-type-value')
  const messagesArea = container.querySelector('#messages-container')

  if (!eventId || !threadType || !messagesArea) return

  function getLastMessageId() {
    const messages = messagesArea.querySelectorAll('[data-message-id]')
    if (messages.length > 0) {
      return parseInt(messages[messages.length - 1].getAttribute('data-message-id'))
    }
    return null
  }

  let lastPollTime = Date.now()
  
  function pollMessages() {
    const now = Date.now()
    if (now - lastPollTime < 1000) return
    lastPollTime = now
    
    const lastId = getLastMessageId()
    
    if (!lastId) return
    
    const url = `/events/${eventId}/discussions/messages_feed?thread_type=${threadType}&after_message_id=${lastId}`

    fetch(url)
      .then(response => {
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
        return response.json()
      })
      .then(data => {
        if (!Array.isArray(data.messages)) return
        
        const existingIds = new Set(
          Array.from(messagesArea.querySelectorAll('[data-message-id]')).map(el => 
            parseInt(el.getAttribute('data-message-id'))
          )
        )
        
        data.messages.forEach(message => {
          if (!existingIds.has(message.id)) {
            const messageDiv = document.createElement('div')
            messageDiv.className = `message ${message.is_own ? 'own-message' : 'other-message'}`
            messageDiv.setAttribute('data-message-id', message.id)
            messageDiv.innerHTML = `
              <div class="message-body">
                <p class="message-content">${escapeHtml(message.content)}</p>
                <p class="message-meta">
                  ${escapeHtml(message.user_name)} • 
                  <span class="time-ago" data-timestamp="${message.timestamp}">just now</span>
                </p>
              </div>
            `
            messagesArea.appendChild(messageDiv)
          }
        })

        if (data.messages.length > 0) {
          messagesArea.scrollTop = messagesArea.scrollHeight
        }
      })
      .catch(error => console.error('Error polling messages:', error))
  }

  function escapeHtml(text) {
    const map = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#039;'
    }
    return text.replace(/[&<>"']/g, m => map[m])
  }

  const pollInterval = setInterval(pollMessages, 1000)

  if (!container._pollIntervals) {
    container._pollIntervals = []
  }
  container._pollIntervals.push(pollInterval)

  const observer = new MutationObserver(() => {
    if (!container.isConnected) {
      container._pollIntervals.forEach(id => clearInterval(id))
      observer.disconnect()
    }
  })

  observer.observe(container, { childList: true, subtree: true })

  const form = container.querySelector('form')
  if (form) {
    let isSubmitting = false
    form.addEventListener('submit', (e) => {
      if (isSubmitting) {
        e.preventDefault()
        e.stopPropagation()
        return
      }
      
      isSubmitting = true
      e.preventDefault()
      e.stopPropagation()

      const formData = new FormData(form)
      const url = form.action
      const submitBtn = form.querySelector('button[type="submit"]')
      const textarea = form.querySelector('textarea')
      const charCount = container.querySelector('#char-count')

      fetch(url, {
        method: 'POST',
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': 'application/json'
        }
      })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
        return response.json()
      })
      .then(data => {
        if (data.success) {
          if (textarea) textarea.value = ''
          if (charCount) charCount.textContent = '0 / 5000'
          if (submitBtn) {
            submitBtn.textContent = 'Send Message'
            submitBtn.disabled = true
          }
          setTimeout(pollMessages, 100)
          setTimeout(() => { isSubmitting = false }, 200)
        } else {
          console.error('Message submission failed:', data.errors)
          isSubmitting = false
          if (submitBtn) {
            submitBtn.textContent = 'Error - please try again'
            setTimeout(() => {
              submitBtn.textContent = 'Send Message'
            }, 2000)
          }
        }
      })
      .catch(error => {
        console.error('Error submitting message:', error)
        isSubmitting = false
        if (submitBtn) {
          submitBtn.textContent = 'Error - check console'
          setTimeout(() => {
            submitBtn.textContent = 'Send Message'
          }, 2000)
        }
      })
    })
  }
}

document.addEventListener('turbo:load', startDiscussionPolling)
document.addEventListener('DOMContentLoaded', startDiscussionPolling)
