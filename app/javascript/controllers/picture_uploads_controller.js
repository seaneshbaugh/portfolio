import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = ["dropzone", "input", "status", "errors", "rows", "empty"];
  static values = { url: String, directUploadUrl: String };

  connect() {
    this.connection = { active: true, pending: 0, operations: new Set() };
    this.updateStatus();
  }

  disconnect() {
    this.connection.active = false;
    this.connection.operations.forEach((operation) => {
      operation.request.abort();
      operation.xhrs.forEach((xhr) => xhr.abort());
      operation.reject?.(new DOMException("Upload cancelled", "AbortError"));
    });
    // Targets may no longer be in the Stimulus scope during disconnect.
    this.element.querySelector(".image-uploader")?.classList.remove("hover");
    const status = this.element.querySelector('[data-picture-uploads-target="status"]');
    if (status) status.hidden = true;
  }

  choose(event) {
    const files = Array.from(event.target.files);
    event.target.value = "";
    files.forEach((file) => this.upload(file));
  }

  dragenter(event) {
    event.preventDefault();
    this.dropzoneTarget.classList.add("hover");
  }

  dragover(event) { event.preventDefault(); }

  dragleave(event) {
    if (!event.currentTarget.contains(event.relatedTarget)) this.dropzoneTarget.classList.remove("hover");
  }

  drop(event) {
    event.preventDefault();
    event.stopPropagation();
    this.dropzoneTarget.classList.remove("hover");
    Array.from(event.dataTransfer.files).forEach((file) => this.upload(file));
  }

  async upload(file) {
    if (!file.type.startsWith("image/")) {
      this.showError(file, "Please choose an image.");
      return;
    }

    const connection = this.connection;
    const operation = { request: new AbortController(), xhrs: new Set() };
    connection.operations.add(operation);
    connection.pending += 1;
    this.updateStatus();

    try {
      const blob = await new Promise((resolve, reject) => {
        operation.reject = reject;
        const trackXHR = (xhr) => operation.xhrs.add(xhr);
        const delegate = {
          directUploadWillCreateBlobWithXHR: trackXHR,
          directUploadWillStoreFileWithXHR: trackXHR
        };
        new DirectUpload(file, this.directUploadUrlValue, delegate).create((error, result) => {
          if (error) reject(new Error("Unable to upload the image. Please try again."));
          else resolve(result);
        });
      });
      if (!connection.active) return;

      const headers = { Accept: "text/html", "Content-Type": "application/json", "X-Requested-With": "XMLHttpRequest" };
      const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;
      if (csrfToken) headers["X-CSRF-Token"] = csrfToken;
      const response = await fetch(this.urlValue, {
        method: "POST", headers, signal: operation.request.signal,
        body: JSON.stringify({ picture: { image: blob.signed_id } })
      });
      if (!connection.active) return;
      if (!response.ok) {
        const json = response.headers.get("Content-Type")?.includes("application/json") ? await response.json() : null;
        throw new Error(json?.errors?.map((error) => error.title).join(". ") || "Unable to save the picture. Please try again.");
      }
      if (response.redirected || !response.headers.get("Content-Type")?.includes("text/html")) {
        throw new Error("Unable to save the picture. Please try again.");
      }
      const tableBody = document.createElement("tbody");
      tableBody.innerHTML = await response.text();
      if (!connection.active) return;
      const row = tableBody.querySelector("tr.picture");
      if (!row) throw new Error("Unable to save the picture. Please try again.");
      this.rowsTarget.prepend(row);
      while (this.rowsTarget.children.length > 25) this.rowsTarget.lastElementChild.remove();
      if (this.hasEmptyTarget) this.emptyTarget.hidden = true;
    } catch (error) {
      if (connection.active) {
        const message = error instanceof TypeError || error instanceof SyntaxError ? "Upload failed. Please try again." : error.message;
        this.showError(file, message);
      }
    } finally {
      connection.operations.delete(operation);
      connection.pending -= 1;
      if (connection.active) this.updateStatus();
    }
  }

  showError(file, message) {
    const item = document.createElement("li");
    item.textContent = `${file.name}: ${message}`;
    this.errorsTarget.append(item);
    this.errorsTarget.hidden = false;
  }

  updateStatus() {
    if (this.hasStatusTarget) this.statusTarget.hidden = this.connection.pending === 0;
  }
}
