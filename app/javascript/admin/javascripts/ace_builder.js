import React from "react";
import { render } from "react-dom";
import brace from "brace";
import AceEditor from "react-ace";

import "brace/mode/html";
import "brace/theme/github";

Array.from(document.querySelectorAll(".ace-editor-field")).forEach(function(aceEditorField, index) {
  const aceEditor = aceEditorField.querySelector(".ace-editor");
  const textArea = aceEditorField.querySelector("textarea");
  const onChange = ((newValue) => {
    textArea.value = newValue;
  });

  render(
    <AceEditor
      mode="html"
      theme="github"
      onChange={onChange}
      name={`ace-editor-${index}`}
      editorProps={{$blockScrolling: true}}
    />,
    aceEditor
  );
});
