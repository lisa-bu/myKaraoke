import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { playlistSongId: Number }
  static targets = ["card", "stack", "deleteBtn"]

  connect() {
    this.startX = 0
    this.currentX = 0
    this.isDragging = false
    this.isSwiped = false
    this.swipeThreshold = 50 // Pixels to trigger swiped state

    // Bind methods once to properly remove listeners
    this.boundTouchStart = this.handleTouchStart.bind(this)
    this.boundTouchMove = this.handleTouchMove.bind(this)
    this.boundTouchEnd = this.handleTouchEnd.bind(this)
    this.boundMouseDown = this.handleMouseDown.bind(this)
    this.boundMouseMove = this.handleMouseMove.bind(this)
    this.boundMouseUp = this.handleMouseUp.bind(this)

    // Touch events on the card (top layer)
    this.cardTarget.addEventListener("touchstart", this.boundTouchStart)
    this.cardTarget.addEventListener("touchmove", this.boundTouchMove)
    this.cardTarget.addEventListener("touchend", this.boundTouchEnd)

    // Mouse events for desktop
    this.cardTarget.addEventListener("mousedown", this.boundMouseDown)
    document.addEventListener("mousemove", this.boundMouseMove)
    document.addEventListener("mouseup", this.boundMouseUp)
  }

  disconnect() {
    this.cardTarget.removeEventListener("touchstart", this.boundTouchStart)
    this.cardTarget.removeEventListener("touchmove", this.boundTouchMove)
    this.cardTarget.removeEventListener("touchend", this.boundTouchEnd)
    this.cardTarget.removeEventListener("mousedown", this.boundMouseDown)
    document.removeEventListener("mousemove", this.boundMouseMove)
    document.removeEventListener("mouseup", this.boundMouseUp)
  }

  // Touch handlers
  handleTouchStart(event) {
    // Don't start swipe if touching play button
    if (event.target.closest(".play-pause-btn")) return

    this.startX = event.touches[0].clientX
    this.currentX = this.startX // Initialize to same position so click doesn't register as swipe
    this.isDragging = true
    this.element.classList.add("swiping")
  }

  handleTouchMove(event) {
    if (!this.isDragging) return

    this.currentX = event.touches[0].clientX
    const diffX = this.startX - this.currentX

    if (this.isSwiped) {
      // Already swiped - allow swiping right to close
      const baseOffset = this.stackTarget.offsetWidth * 0.25
      if (diffX < 0) {
        // Swiping right - move stack back towards original position
        const newOffset = Math.max(0, baseOffset + diffX)
        this.stackTarget.style.transform = `translateX(-${newOffset}px)`
      }
    } else {
      // Not swiped yet - only allow swiping left
      if (diffX > 0) {
        const translateX = Math.min(diffX, 100)
        this.stackTarget.style.transform = `translateX(-${translateX}px)`
      } else {
        this.stackTarget.style.transform = ""
      }
    }
  }

  handleTouchEnd() {
    if (!this.isDragging) return
    this.isDragging = false
    this.element.classList.remove("swiping")

    const diffX = this.startX - this.currentX

    if (this.isSwiped) {
      // Already swiped - check if user swiped right enough to close
      if (diffX < -30) {
        // Close the delete button
        this.isSwiped = false
        this.element.classList.remove("swiped")
      }
      // Reset transform - CSS will handle the position
      this.stackTarget.style.transform = ""
    } else {
      // Not swiped yet
      if (diffX > this.swipeThreshold) {
        // Swiped left enough - show delete button
        this.isSwiped = true
        this.element.classList.add("swiped")
      }
      this.stackTarget.style.transform = ""
    }
  }

  // Mouse handlers for desktop
  handleMouseDown(event) {
    // Don't start swipe if clicking play button
    if (event.target.closest(".play-pause-btn")) return

    this.startX = event.clientX
    this.currentX = this.startX // Initialize to same position so click doesn't register as swipe
    this.isDragging = true
    this.element.classList.add("swiping")
    event.preventDefault()
  }

  handleMouseMove(event) {
    if (!this.isDragging) return

    this.currentX = event.clientX
    const diffX = this.startX - this.currentX

    if (this.isSwiped) {
      const baseOffset = this.stackTarget.offsetWidth * 0.25
      if (diffX < 0) {
        const newOffset = Math.max(0, baseOffset + diffX)
        this.stackTarget.style.transform = `translateX(-${newOffset}px)`
      }
    } else {
      if (diffX > 0) {
        const translateX = Math.min(diffX, 100)
        this.stackTarget.style.transform = `translateX(-${translateX}px)`
      } else {
        this.stackTarget.style.transform = ""
      }
    }
  }

  handleMouseUp() {
    if (!this.isDragging) return
    this.isDragging = false
    this.element.classList.remove("swiping")

    const diffX = this.startX - this.currentX

    if (this.isSwiped) {
      if (diffX < -30) {
        this.isSwiped = false
        this.element.classList.remove("swiped")
      }
      this.stackTarget.style.transform = ""
    } else {
      if (diffX > this.swipeThreshold) {
        this.isSwiped = true
        this.element.classList.add("swiped")
      }
      this.stackTarget.style.transform = ""
    }
  }

  // Called when red X button is clicked
  confirmDelete(event) {
    event.preventDefault()
    event.stopPropagation()
    this.removeSong()
  }

  removeSong() {
    const wasNowPlaying = this.element.classList.contains("now-playing")
    this.element.classList.add("removing")

    fetch(`/playlist_songs/${this.playlistSongIdValue}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html"
      }
    }).then(() => {
      setTimeout(() => {
        // Get the next sibling before removing
        const nextSibling = this.element.nextElementSibling
        this.element.remove()

        // If this was the "now playing" song, promote the next one
        if (wasNowPlaying && nextSibling && nextSibling.classList.contains("song-card-wrapper")) {
          nextSibling.classList.add("now-playing")
        }
      }, 300)
    }).catch(() => {
      this.element.classList.remove("removing", "swiped")
      this.isSwiped = false
    })
  }
}
