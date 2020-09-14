import React from "react";
import { render } from "react-dom";
import AceEditor from "react-ace";
import PictureSelector from "./components/picture_selector";
// import TagList from "./components/tag_list";

import "ace-builds/src-noconflict/mode-css";
import "ace-builds/src-noconflict/mode-html";
import "ace-builds/src-noconflict/mode-javascript";
import "ace-builds/src-noconflict/mode-text";
import "ace-builds/src-noconflict/mode-rhtml";
import "ace-builds/src-noconflict/theme-github";

const completed = () => {
  document.querySelectorAll(".ace-editor-field").forEach((aceEditorField, index) => {
    const aceEditor = aceEditorField.querySelector(".ace-editor");
    const mode = aceEditor.dataset.mode;
    const theme = aceEditor.dataset.theme;
    const textArea = aceEditorField.querySelector("textarea.value");
    const label = aceEditorField.querySelector("label");
    const onChange = ((newValue) => {
      textArea.value = newValue;
    });

    label.classList.remove("active");

    render(
      <AceEditor
        mode={mode}
        theme={theme}
        onChange={onChange}
        name={`ace-editor-${index}`}
        editorProps={{ "$blockScrolling": true }}
        height="300px"
        width="100%"
        wrapEnabled={true}
        value={textArea.value}
      />,
      aceEditor
    );
  });

  document.querySelectorAll(".picture-inserter").forEach((pictureInserter) => {
    const target = pictureInserter.dataset.target;

    const editor = document.querySelector(`#${target} .ace_editor`).env.editor;

    const insertPicture = (picture) => {
      let image = `<img src="${picture.data.attributes.original_image_url}"`;

      if (picture.data.attributes.alt_text) {
        image += ` alt=${picture.data.attributes.alt_text}"`;
      }

      image += ">";

      editor.insert(image);
    };

    render(
      <PictureSelector
        buttonClassName={pictureInserter.dataset.buttonclassname}
        buttonText={pictureInserter.dataset.buttontext}
        onSelect={insertPicture}
      />,
      pictureInserter
    );
  });

  // TODO: I18nize the placeholder text. Need to figure out how to make the Rails I18n
  // locales available here.
  // Maybe try https://github.com/mikamai/rails-translations-webpack-plugin?
  // TODO: This AJAX request probably isn't needed anymore. Leaving it in in case I change
  // my mind.
  // window.fetch("/admin/tags.json", {
  //   "method": "GET",
  //   "headers": {
  //     "Accept": "application/json",
  //     "Content-Type": "application/json"
  //   }
  // }).then((response) => {
  //   return response.json();
  // }).then((json) => {
  //   document.querySelectorAll(".taglist-container").forEach((taglistContainer, index) => {
  //     const tags = taglistContainer.dataset["tags"].split(",").filter((tag) => tag);
  //     const suggestions = taglistContainer.dataset["suggestions"].split(",").filter((suggestion) => suggestion);
  //     const objectName = taglistContainer.dataset["objectname"];
  //     const method = taglistContainer.dataset["method"];

  //     render(
  //       <TagList
  //         tags={tags}
  //         suggestions={suggestions}
  //         objectName={objectName}
  //         method={method}
  //       />,
  //       taglistContainer
  //     );
  //   });
  // });
};

if (document.readyState === "complete") {
  window.setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
