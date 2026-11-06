const completed = () => {
  document.querySelectorAll(".flash-message").forEach((flashMessage, index) => {
    flashMessage.addEventListener("click", (event) => {
      flashMessage.classList.add("animate__animated", "animate__fadeOutUp");
    });

    flashMessage.addEventListener("animationend", (event) => {
      flashMessage.remove();
    });
  });
};

if (document.readyState !== "loading") {
  setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
