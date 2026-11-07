import { Controller } from "@hotwired/stimulus";
import ace from "lib/ace";

export default class extends Controller {
  static targets = ["editor", "input"];
  static values = { mode: { type: String, default: "text" }, theme: { type: String, default: "github" } };

  connect() {
    this.input = this.inputTarget;
    this.container = this.editorTarget;
    this.container.style.height = "300px";
    this.container.style.width = "100%";
    this.editor = ace.edit(this.container, {
      mode: `ace/mode/${this.modeValue}`,
      theme: `ace/theme/${this.themeValue}`,
      wrap: true
    });

    this.editor.setValue(this.input.value, -1);
    this.synchronize = () => { this.input.value = this.editor.getValue(); };
    this.editor.on("change", this.synchronize);
    this.element.querySelector("label")?.classList.remove("active");

    this.insertPicture = (event) => {
      const attributes = event.detail.picture.data.attributes;
      const image = document.createElement("img");

      image.setAttribute("src", attributes.original_image_url);

      if (attributes.alt_text) {
        image.setAttribute("alt", attributes.alt_text);
      }

      this.editor.insert(image.outerHTML);
    };
    this.pictureInserters = Array.from(this.element.closest("form").querySelectorAll(".picture-inserter"))
      .filter((selector) => selector.dataset.target === this.container.id);

    this.pictureInserters.forEach((selector) => {
      selector.addEventListener("picture-selector:select", this.insertPicture);
      selector.dataset.pictureSelectorReadyValue = "true";
    });
  }

  disconnect() {
    if (!this.editor) {
      return;
    }

    this.pictureInserters.forEach((selector) => {
      selector.removeEventListener("picture-selector:select", this.insertPicture);
      selector.dataset.pictureSelectorReadyValue = "false";
    });
    this.synchronize();
    this.editor.off("change", this.synchronize);
    this.editor.destroy();
    this.container.replaceChildren();
    this.container.classList.remove("ace_editor", "ace_focus");
    this.editor = null;
  }
}
