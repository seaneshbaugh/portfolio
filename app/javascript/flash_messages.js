// Delegation survives Turbo body replacements without rebinding listeners.
document.addEventListener("click", event => {
  event.target.closest(".flash-message")?.classList.add("animate__animated", "animate__fadeOutUp");
});
document.addEventListener("animationend", event => {
  event.target.closest(".flash-message")?.remove();
});
