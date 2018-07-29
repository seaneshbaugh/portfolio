import React from "react";
import { render } from "react-dom";
import brace from "brace";
import AceEditor from "react-ace";
import PictureSelector from "./components/picture_selector";

import "brace/mode/css";
import "brace/mode/html";
import "brace/mode/javascript";
import "brace/mode/text";
import "brace/mode/rhtml";
import "brace/theme/github";

const completed = () => {
  Array.from(document.querySelectorAll(".ace-editor-field")).forEach((aceEditorField, index) => {
    const aceEditor = aceEditorField.querySelector(".ace-editor");
    const mode = aceEditor.dataset.mode;
    const theme = aceEditor.dataset.theme;
    const textArea = aceEditorField.querySelector("textarea.value");
    const onChange = ((newValue) => {
      textArea.value = newValue;
    });

    render(
      <AceEditor
        mode={mode}
        theme={theme}
        onChange={onChange}
        name={`ace-editor-${index}`}
        editorProps={{ "$blockScrolling": true }}
        height="300px"
        width="100%"
      />,
      aceEditor
    );
  });

  Array.from(document.querySelectorAll(".picture-selector")).forEach((pictureSelector, index) => {
    render(
      <PictureSelector
        buttonClassName={pictureSelector.dataset.buttonclassname}
        buttonText={pictureSelector.dataset.buttontext}
        target={pictureSelector.dataset.target}
      />,
      pictureSelector
    );
  });
};

if (document.readyState === "complete") {
  setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
