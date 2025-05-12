import { AutoInit } from "@materializecss/materialize";
import "./flash_messages";

const completed = () => (AutoInit());

if (document.readyState === "complete") {
  setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
