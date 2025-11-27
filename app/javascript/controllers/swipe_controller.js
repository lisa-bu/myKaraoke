import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {

    console.log("connected")

  }

  hide(event) {
    const listItem = event.target.closest('li')
    listItem.classList.add('hidden')
  }
}
