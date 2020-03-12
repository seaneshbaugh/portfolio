import React from "react";
import { render } from "react-dom";
import AceEditor from "react-ace";
import PictureSelector from "./components/picture_selector";

import "ace-builds/src-noconflict/mode-css";
import "ace-builds/src-noconflict/mode-html";
import "ace-builds/src-noconflict/mode-javascript";
import "ace-builds/src-noconflict/mode-text";
import "ace-builds/src-noconflict/mode-rhtml";
import "ace-builds/src-noconflict/theme-github";

const completed = () => {
  Array.from(document.querySelectorAll(".ace-editor-field")).forEach((aceEditorField, index) => {
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
  window.setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
