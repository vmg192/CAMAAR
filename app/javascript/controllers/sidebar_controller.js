import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["view"]

  toggle() {
    // this.viewTarget.classList.toggle("-translate-x-full")

    // this.contentTarget.classList.toggle("ml-[257px]")
    this.viewTarget.classList.toggle("w-[257px]")
    this.viewTarget.classList.toggle("w-0")
  }
}