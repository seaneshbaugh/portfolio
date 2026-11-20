import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "error", "pageError", "overlay", "modal", "closeButton", "pictures", "pictureTemplate", "loadMore"];
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

    if (this.request || !this.readyValue) {
      return;
    }

    this.pictures = new Map();
    this.picturesTarget.replaceChildren();
    this.nextPage = 1;

    await this.loadPage(1);
  }

  async loadMore(event) {
    event.preventDefault();

    if (!this.request && this.nextPage) {
      await this.loadPage(this.nextPage);
    }
  }

  async loadPage(page) {
    const request = new AbortController();
    this.request = request;
    this.buttonTarget.disabled = true;

    // Disabling the focused button drops focus in Firefox. Keep it in the dialog.
    if (document.activeElement === this.loadMoreTarget) {
      this.closeButtonTarget.focus();
    }

    this.loadMoreTarget.disabled = true;
    this.loadMoreTarget.hidden = false;
    this.loadMoreTarget.textContent = "Loading pictures…";
    this.errorTarget.hidden = true;
    this.pageErrorTarget.hidden = true;

    try {
      const url = new URL(this.urlValue, window.location.href);

      url.searchParams.set("page", page);

      const response = await fetch(url, {
        headers: { Accept: "application/json" },
        signal: request.signal
      });

      if (!response.ok) {
        throw new Error("Unable to load pictures.");
      }

      const pictures = await response.json();

      if (!Array.isArray(pictures)) {
        throw new Error("Unexpected picture response.");
      }

      if (request.signal.aborted) {
        return;
      }

      for (const picture of pictures) {
        const id = String(picture.data.id);

        if (this.pictures.has(id)) {
          continue;
        }

        const fragment = this.pictureTemplateTarget.content.cloneNode(true);
        const button = fragment.querySelector("button");
        const image = fragment.querySelector("img");
        const attributes = picture.data.attributes;

        button.dataset.pictureId = id;
        image.src = attributes.thumbnail_image_path;
        image.alt = attributes.alt_text || "";

        fragment.querySelector(".title").textContent = attributes.title;

        this.pictures.set(id, picture);
        this.picturesTarget.append(fragment);
      }

      this.nextPage = response.headers.get("X-Next-Page") || null;

      if (page === 1) {
        this.modalTarget.hidden = false;
        this.overlayTarget.hidden = false;
        this.closeButtonTarget.focus();
      }

      // Keep focus in the dialog when the final Load more button disappears.
      if (!this.nextPage && document.activeElement === this.loadMoreTarget) {
        this.closeButtonTarget.focus();
      }
    } catch (error) {
      if (error.name !== "AbortError") {
        const target = page === 1 ? this.errorTarget : this.pageErrorTarget;

        target.textContent = "Unable to load pictures. Please try again.";
        target.hidden = false;
      }
    } finally {
      if (this.request === request) {
        this.buttonTarget.disabled = !this.readyValue;
        this.loadMoreTarget.disabled = false;
        this.loadMoreTarget.hidden = !this.nextPage;
        this.loadMoreTarget.textContent = "Load more pictures";
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

    if (this.modalTarget.hidden) {
      return;
    }

    this.request?.abort();
    this.request = null;
    this.buttonTarget.disabled = !this.readyValue;
    this.modalTarget.hidden = true;
    this.overlayTarget.hidden = true;
    this.buttonTarget.focus();
  }

  keydown(event) {
    if (this.modalTarget.hidden) {
      return;
    }

    if (event.key === "Escape") {
      this.close(event);
    }

    if (event.key !== "Tab") {
      return;
    }

    const buttons = this.modalTarget.querySelectorAll("button:not([disabled]):not([hidden])");
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
