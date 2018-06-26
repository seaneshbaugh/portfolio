import { DirectUpload } from "activestorage";
import serialize from "form-serialize";

const completed = () => {
  Array.from(document.querySelectorAll("input[type=file].image-uploader")).forEach((fileInput) => {
    const onDrop = (event) => {
      event.preventDefault();
      const files = event.dataTransfer.files;
      Array.from(files).forEach(file => uploadFile(file));
    };

    const uploadFile = (file) => {
      const url = fileInput.dataset.directUploadUrl;
      const upload = new DirectUpload(file, url);

      upload.create((error, blob) => {
        if (error) {
          // TODO: Handle the error.
        } else {
          const hiddenField = document.createElement("input");
          hiddenField.setAttribute("type", "hidden");
          hiddenField.setAttribute("value", blob.signed_id);
          hiddenField.name = fileInput.name;

          const form = fileInput.closest("form");
          form.appendChild(hiddenField);

          const params = serialize(form, { "hash": true });
          console.log(params);
          fetch(form.action, {
            "method": "POST",
            "headers": {
              "Content-Type": "application/json"
            },
            "body": JSON.stringify(params)
          }).then((response) => {
            console.log(response);

            return response.json();
          }).then((jeon) => console.log(json));
        }
      });
    };

    fileInput.addEventListener("change", (event) => {
      Array.from(fileInput.files).forEach(file => uploadFile(file));
      fileInput.value = null;
    });
  });
};

if (document.readyState === "complete") {
  setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
