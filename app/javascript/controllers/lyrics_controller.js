import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.body.style.overflow = "hidden"
  }

  close() {
    const container = document.getElementById("lyrics_container")
    if (container) {
      container.innerHTML = ""
    }
    document.body.style.overflow = ""
  }

  disconnect() {
    document.body.style.overflow = ""
  }
}
