import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["info", "text"]

  connect() {
    this.isScrolling = false
    this.checkOverflow()
  }

  checkOverflow() {
    // Check if text is overflowing
    const info = this.infoTarget
    const text = this.textTarget
    this.hasOverflow = text.scrollWidth > info.clientWidth
  }

  toggle(event) {
    // Don't trigger if clicking on buttons
    if (event.target.closest(".play-pause-btn") ||
        event.target.closest(".add-to-queue-btn") ||
        event.target.closest(".done-btn")) {
      return
    }

    if (!this.hasOverflow) return

    if (this.isScrolling) {
      this.stopScrolling()
    } else {
      this.startScrolling()
    }
  }

  startScrolling() {
    // Duplicate the text content for seamless loop
    const text = this.textTarget
    const originalText = text.textContent
    text.textContent = originalText + "     •     " + originalText

    this.infoTarget.classList.add("scrolling")
    this.isScrolling = true
  }

  stopScrolling() {
    const text = this.textTarget
    // Remove the duplicated text
    const parts = text.textContent.split("     •     ")
    text.textContent = parts[0]

    this.infoTarget.classList.remove("scrolling")
    this.isScrolling = false
  }
}
