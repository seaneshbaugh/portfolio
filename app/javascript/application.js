import "shared";
import GLightbox from "glightbox";

const initialize = () => GLightbox({ selector: ".lightbox" });
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initialize, { once: true });
} else {
  initialize();
}
