import "shared";
import GLightbox from "glightbox";

let lightbox;
const teardown = () => {
  if (!lightbox) {
    return;
  }

  // Complete closing synchronously before Turbo clones or replaces the body.
  lightbox.settings.closeEffect = "none";
  lightbox.settings.openEffect = "none";
  lightbox.destroy();
  lightbox = null;
};

document.addEventListener("turbo:load", () => {
  teardown();

  lightbox = GLightbox({ selector: ".lightbox" });
});
document.addEventListener("turbo:before-cache", teardown);
document.addEventListener("turbo:before-render", teardown);
