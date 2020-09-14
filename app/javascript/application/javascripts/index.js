import GLightbox from 'glightbox';

const completed = () => (GLightbox({
  selector: ".lightbox"
}));

if (document.readyState === "complete") {
  setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
