import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.checkOverflow()
    window.addEventListener("resize", this.checkOverflow.bind(this))
  }

  disconnect() {
    window.removeEventListener("resize", this.checkOverflow.bind(this))
  }

  checkOverflow() {
    const wrapper = this.element
    const scroll = wrapper.querySelector(".song-info-scroll")

    if (scroll && scroll.scrollWidth > wrapper.clientWidth) {
      wrapper.classList.add("has-overflow")
    } else {
      wrapper.classList.remove("has-overflow")
    }
  }
}
