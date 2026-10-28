import React from "react";
import { createRoot } from "react-dom/client";
import AceEditor from "react-ace";
import PictureSelector from "./components/picture_selector";
// import TagList from "./components/tag_list";

import "ace-builds/webpack-resolver";
import "ace-builds/src-noconflict/mode-css";
import "ace-builds/src-noconflict/mode-html";
import "ace-builds/src-noconflict/mode-javascript";
import "ace-builds/src-noconflict/mode-text";
import "ace-builds/src-noconflict/mode-rhtml";
import "ace-builds/src-noconflict/theme-github";

const completed = () => {
  document.querySelectorAll(".ace-editor-field").forEach((aceEditorField, index) => {
    const aceEditor = aceEditorField.querySelector(".ace-editor");
    const root = createRoot(aceEditor);
    const mode = aceEditor.dataset.mode;
    const theme = aceEditor.dataset.theme;
    const textArea = aceEditorField.querySelector("textarea.value");
    const label = aceEditorField.querySelector("label");
    const onChange = ((newValue) => {
      textArea.value = newValue;
    });

    label.classList.remove("active");

    const onLoad = (editor) => {
      document.querySelectorAll(".picture-inserter").forEach((pictureInserter) => {
        if (pictureInserter.dataset.target !== aceEditor.id) return;

        const selectorRoot = createRoot(pictureInserter);
        const insertPicture = (picture) => {
          const image = document.createElement("img");
          image.setAttribute("src", picture.data.attributes.original_image_url);
          if (picture.data.attributes.alt_text) {
            image.setAttribute("alt", picture.data.attributes.alt_text);
          }
          editor.insert(image.outerHTML);
        };

        selectorRoot.render(
          <PictureSelector
            buttonClassName={pictureInserter.dataset.buttonclassname}
            buttonText={pictureInserter.dataset.buttontext}
            onSelect={insertPicture}
          />);
      });
    };

    root.render(
      <AceEditor
        mode={mode}
        theme={theme}
        onChange={onChange}
        onLoad={onLoad}
        name={`ace-editor-${index}`}
        editorProps={{ "$blockScrolling": true }}
        height="300px"
        width="100%"
        wrapEnabled={true}
        value={textArea.value}
      />);
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

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", completed, { once: true });
} else {
  completed();
}
