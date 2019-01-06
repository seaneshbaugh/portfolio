import React from "react";
import { render } from "react-dom";
import TagList from "../components/tag_list";

// TODO: I18nize the placeholder text. Need to figure out how to make the Rails
// I18n locales available here.
// Maybe try https://github.com/mikamai/rails-translations-webpack-plugin?
const completed = () => {
  // This AJAX request probably isn't needed anymore. Leaving it in in case I
  // change my mind.
  window.fetch("/admin/tags.json", {
    "method": "GET",
    "headers": {
      "Accept": "application/json",
      "Content-Type": "application/json"
    }
  }).then((response) => {
    return response.json();
  }).then((json) => {
    Array.from(document.querySelectorAll(".taglist-container")).forEach((taglistContainer, index) => {
      const tags = taglistContainer.dataset["tags"].split(",").filter((tag) => tag);
      const suggestions = taglistContainer.dataset["suggestions"].split(",").filter((suggestion) => suggestion);
      const objectName = taglistContainer.dataset["objectname"];
      const method = taglistContainer.dataset["method"];

      render(
        <TagList
          tags={tags}
          suggestions={suggestions}
          objectName={objectName}
          method={method}
        />,
        taglistContainer
      );
    });
  });
};

if (document.readyState === "complete") {
  window.setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
