import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "error", "overlay", "modal", "closeButton", "pictures", "pictureTemplate"];
  static values = { url: String, ready: { type: Boolean, default: true } };

  readyValueChanged() {
    this.buttonTarget.disabled = !this.readyValue || Boolean(this.request);
  }

  disconnect() {
    this.request?.abort();
    this.request = null;
    this.buttonTarget.disabled = !this.readyValue;
    this.modalTarget.hidden = true;
    this.overlayTarget.hidden = true;
  }

  async open(event) {
    event.preventDefault();
    if (this.request || !this.readyValue) return;

    const request = new AbortController();
    this.request = request;
    this.buttonTarget.disabled = true;
    this.errorTarget.hidden = true;

    try {
      const response = await fetch(this.urlValue, {
        headers: { Accept: "application/json" },
        signal: request.signal
      });
      if (!response.ok) throw new Error("Unable to load pictures.");
      const pictures = await response.json();
      if (!Array.isArray(pictures)) throw new Error("Unexpected picture response.");
      if (request.signal.aborted) return;

      this.pictures = new Map();
      this.picturesTarget.replaceChildren();
      for (const picture of pictures) {
        const fragment = this.pictureTemplateTarget.content.cloneNode(true);
        const button = fragment.querySelector("button");
        const image = fragment.querySelector("img");
        const attributes = picture.data.attributes;
        button.dataset.pictureId = picture.data.id;
        image.src = attributes.thumbnail_image_path;
        image.alt = attributes.alt_text || "";
        fragment.querySelector(".title").textContent = attributes.title;
        this.pictures.set(String(picture.data.id), picture);
        this.picturesTarget.append(fragment);
      }

      this.modalTarget.hidden = false;
      this.overlayTarget.hidden = false;
      this.closeButtonTarget.focus();
    } catch (error) {
      if (error.name !== "AbortError") {
        this.errorTarget.textContent = "Unable to load pictures. Please try again.";
        this.errorTarget.hidden = false;
      }
    } finally {
      if (this.request === request) {
        this.buttonTarget.disabled = !this.readyValue;
        this.request = null;
      }
    }
  }

  select(event) {
    event.preventDefault();
    const picture = this.pictures.get(event.currentTarget.dataset.pictureId);
    this.dispatch("select", { detail: { picture } });
    this.close();
  }

  close(event) {
    event?.preventDefault();
    if (this.modalTarget.hidden) return;

    this.modalTarget.hidden = true;
    this.overlayTarget.hidden = true;
    this.buttonTarget.focus();
  }

  keydown(event) {
    if (this.modalTarget.hidden) return;
    if (event.key === "Escape") this.close(event);
    if (event.key !== "Tab") return;

    const buttons = this.modalTarget.querySelectorAll("button:not([disabled])");
    const first = buttons[0];
    const last = buttons[buttons.length - 1];
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  }
}
