import Rails from "@rails/ujs";
import { AutoInit } from "@materializecss/materialize";
import "flash_messages";

Rails.start();
const initialize = () => AutoInit();
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initialize, { once: true });
} else {
  initialize();
}
