import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "messages", "submit"]

  static values = {
    url: String
  }

  async submit(event) {
    event.preventDefault()
  
    const question = this.inputTarget.value.trim()
  
    if (!question) {
      return
    }
  
    const userMessage = document.createElement("div")
  
    userMessage.className =
      "ml-auto max-w-2xl rounded-2xl bg-emerald-600 px-5 py-4 text-white"
  
    userMessage.textContent = question
  
    this.messagesTarget.appendChild(userMessage)
  
    this.inputTarget.value = ""
  
    this.submitTarget.disabled = true
    this.submitTarget.value = "Thinking..."
  
    const assistantMessage = document.createElement("div")
  
    assistantMessage.className =
      "mr-auto max-w-2xl rounded-2xl bg-slate-100 px-5 py-4 text-slate-900"
  
    assistantMessage.textContent = ""
  
    this.messagesTarget.appendChild(assistantMessage)
  
    try {
      const csrfToken = document.querySelector(
        'meta[name="csrf-token"]'
      )?.content
  
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/event-stream",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({
          content: question
        })
      })
  
      if (!response.ok) {
        throw new Error(
          `Streaming request failed: ${response.status}`
        )
      }
  
      console.log("Streaming response started")
  
      const reader = response.body.getReader()
      const decoder = new TextDecoder()
  
      let buffer = ""
  
      while (true) {
        const { value, done } = await reader.read()
  
        if (done) {
          break
        }
  
        buffer += decoder.decode(value, {
          stream: true
        })
  
        const events = buffer.split("\n\n")
        buffer = events.pop() || ""
  
        for (const event of events) {
          if (event.startsWith("event: done")) {
            const dataLine = event
              .split("\n")
              .find((line) => line.startsWith("data: "))
        
            if (dataLine) {
              const data = JSON.parse(dataLine.slice(6))
        
              await this.renderMarkdown(
                data.message_id,
                assistantMessage
              )
            }
        
            continue
          }
        
          if (event.startsWith("event: error")) {
            const dataLine = event
              .split("\n")
              .find((line) => line.startsWith("data: "))
        
            if (dataLine) {
              const data = JSON.parse(dataLine.slice(6))

              assistantMessage.className = "mr-auto max-w-2xl rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-red-700"
        
              assistantMessage.textContent = data.message
            }
        
            continue
          }
        
          const dataLine = event
            .split("\n")
            .find((line) => line.startsWith("data: "))
        
          if (!dataLine) {
            continue
          }
        
          const json = dataLine.slice(6)
        
          try {
            const chunk = JSON.parse(json)
            assistantMessage.textContent += chunk
          } catch (error) {
            console.error(
              "Unable to parse stream chunk:",
              error
            )
          }
        }
      }
    } catch (error) {
      console.error("AI streaming error:", error)
    } finally {
      this.submitTarget.disabled = false
      this.submitTarget.value = "Send"
    }
  }

  async renderMarkdown(messageId, element) {
    const baseUrl = this.urlValue.replace(/\/stream$/, "")
  
    const response = await fetch(
      `${baseUrl}/${messageId}/rendered`,
      {
        headers: {
          "Accept": "text/html"
        }
      }
    )
  
    if (!response.ok) {
      throw new Error(
        `Markdown request failed: ${response.status}`
      )
    }
  
    const html = await response.text()
  
    element.innerHTML = html
  }
}