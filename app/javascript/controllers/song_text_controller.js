import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["info", "text"]

  connect() {
    this.isScrolling = false
    // Store the original full text before any truncation
    this.originalText = this.textTarget.textContent
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
    const text = this.textTarget
    // Use the stored original text (not the truncated version)
    text.textContent = this.originalText + "     •     " + this.originalText

    this.infoTarget.classList.add("scrolling")
    this.isScrolling = true
  }

  stopScrolling() {
    const text = this.textTarget
    // Restore original text
    text.textContent = this.originalText

    this.infoTarget.classList.remove("scrolling")
    this.isScrolling = false
  }
}
