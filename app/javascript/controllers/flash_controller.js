import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.dismissing = false;

    this.element.classList.remove("opacity-0");
  }

  dismiss(event) {
    if (event.target.closest("a") || this.dismissing) {
      return;
    }

    this.dismissing = true;

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.element.remove();

      return;
    }

    this.element.classList.add("opacity-0");
    this.timeout = setTimeout(() => this.element.remove(), 200);
  }

  disconnect() {
    clearTimeout(this.timeout);
  }
}
