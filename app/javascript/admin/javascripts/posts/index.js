import React from "react";
import { render } from "react-dom";
//import TokenAutocomplete from "react-token-autocomplete";

// TODO: I18nize the placeholder text. Need to figure out how to make the Rails
// I18n locales available here.
// Maybe try https://github.com/mikamai/rails-translations-webpack-plugin?
const completed = () => {
  window.fetch("/admin/tags.json", {
    "method": "GET",
    "headers": {
      "Accept": "application/json",
      "Content-Type": "application/json"
    }
  }).then((response) => {
    return response.json();
  }).then((json) => {
    // Array.from(document.querySelectorAll(".taglist")).forEach((taglistField, index) => {
    //   render(
    //     <TokenAutocomplete
    //       placeholder="Tags"
    //       options={json}
    //     />,
    //     taglistField
    //   );
    // });
  });
};

if (document.readyState === "complete") {
  window.setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
