import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {

  }

  hide(event) {
    const listItem = event.target.closest('li')
    listItem.classList.add('hidden')
  }
}
