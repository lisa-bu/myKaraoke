import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Spotify controller connected!")
  }

  confirm(event) {
    const ok = confirm(
      "Would you like to sign into Spotify for a bespoke suggestion from your library?"
    )

    if (!ok) {
      event.preventDefault()
      event.stopImmediatePropagation()
    }
  }
}
