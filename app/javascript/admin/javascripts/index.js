import "materialize-css/dist/js/materialize.js";

import "./ace_builder";
import "./pictures";

const completed = () => (M.AutoInit());

if (document.readyState === "complete") {
  setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
