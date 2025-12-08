import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["view"]

  toggle() {
    this.viewTarget.classList.toggle("hidden")
  }
}