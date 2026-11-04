import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["rows", "template", "selector", "status"];

  connect() {
    this.selector = this.selectorTarget.querySelector('[data-controller~="picture-selector"]');
    this.nextIndex = Math.max(0, ...Array.from(this.rowsTarget.children, (row) => Number(row.dataset.galleryIndex) + 1));
    this.synchronizeOrder();
    this.selector.dataset.pictureSelectorReadyValue = "true";
  }

  disconnect() {
    this.selector.dataset.pictureSelectorReadyValue = "false";
    this.dragend();
  }

  get rows() {
    return Array.from(this.rowsTarget.children).filter((row) => !row.hidden);
  }

  field(row, name) { return row.querySelector(`[data-gallery-picture-field="${name}"]`); }

  add(event) {
    const picture = event.detail.picture;
    const fragment = this.templateTarget.content.cloneNode(true);
    const index = String(this.nextIndex++);

    fragment.querySelectorAll("[name], [id], [for], [data-gallery-index]").forEach((element) => {
      ["name", "id", "for", "data-gallery-index"].forEach((attribute) => {
        if (element.hasAttribute(attribute)) {
          element.setAttribute(attribute, element.getAttribute(attribute).replaceAll("NEW_GALLERY_PICTURE", index));
        }
      });
    });

    const row = fragment.querySelector(".gallery-picture");

    this.field(row, "picture_id").value = picture.data.id;

    const image = row.querySelector("img");

    image.src = picture.data.attributes.thumbnail_image_path;
    image.alt = picture.data.attributes.alt_text || "";

    row.querySelector(".gallery-picture-title").textContent = picture.data.attributes.title;

    this.rowsTarget.append(fragment);
    this.synchronizeOrder();

    row.scrollIntoView({ behavior: "smooth", block: "nearest" });
  }

  remove(event) {
    const row = event.currentTarget.closest(".gallery-picture");
    const next = this.rows[this.rows.indexOf(row) + 1] || this.rows[this.rows.indexOf(row) - 1];

    if (this.field(row, "id")) {
      this.field(row, "_destroy").value = "1";

      row.hidden = true;
    } else {
      row.remove();
    }

    this.synchronizeOrder();

    (next?.querySelector(".gallery-picture-drag") || this.selector.querySelector("button")).focus();
  }

  feature(event) {
    if (!event.target.checked) {
      return;
    }

    this.rows.forEach((row) => {
      const checkbox = this.field(row, "featured");

      if (checkbox !== event.target) {
        checkbox.checked = false;
      }
    });
  }

  up(event) {
    this.move(event, -1);
  }

  down(event) {
    this.move(event, 1);
  }

  move(event, direction) {
    const row = event.currentTarget.closest(".gallery-picture");
    const neighbour = this.rows[this.rows.indexOf(row) + direction];

    if (!neighbour) {
      return;
    }

    neighbour[direction < 0 ? "before" : "after"](row);

    this.synchronizeOrder();

    event.currentTarget.focus({ preventScroll: true });

    this.announce(row);
  }

  dragstart(event) {
    if (event.target.closest("input, label, button:not(.gallery-picture-drag), a")) {
      event.preventDefault();

      return;
    }

    this.dragged = event.currentTarget;

    this.dragged.classList.add("dragging");

    event.dataTransfer.effectAllowed = "move";
    event.dataTransfer.setData("text/plain", this.dragged.dataset.galleryIndex);
  }

  dragover(event) {
    if (!this.dragged) {
      return;
    }

    event.preventDefault();

    event.dataTransfer.dropEffect = "move";
  }

  drop(event) {
    if (!this.dragged) {
      return;
    }

    event.preventDefault();

    const target = event.currentTarget;
    const row = this.dragged;

    if (target !== row) {
      const bounds = target.getBoundingClientRect();

      target[event.clientY < bounds.top + bounds.height / 2 ? "before" : "after"](row);

      this.synchronizeOrder();
      this.announce(row);
    }

    this.dragend();
  }

  dragend() {
    this.dragged?.classList.remove("dragging");
    this.dragged = null;
  }

  synchronizeOrder() {
    this.rows.forEach((row, index) => { this.field(row, "order").value = index; });
  }

  announce(row) {
    this.statusTarget.textContent = `${row.querySelector(".gallery-picture-title").textContent} moved to position ${this.rows.indexOf(row) + 1} of ${this.rows.length}.`;
  }
}
