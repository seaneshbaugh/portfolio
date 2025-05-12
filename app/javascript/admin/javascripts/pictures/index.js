import React from "react";
import { createRoot } from "react-dom/client";
import { createStore } from "redux";
import { Provider } from "react-redux";

import picturesReducer from "../reducers/pictures_reducer";
import ImageUploader from "../components/image_uploader";
import PictureList from "../components/picture_list";

const completed = () => {
  const imageUploaderContainer = document.querySelector(".image-uploader-container");
  const pictureListContainer = document.querySelector(".picture-list-container");

  if (!imageUploaderContainer || !pictureListContainer) {
    return;
  }

  const imageUploaderRoot = createRoot(imageUploaderContainer);
  const pictureListRoot = createRoot(pictureListRoot);

  window.picturesStore = createStore(picturesReducer, { "pictures": JSON.parse(pictureListContainer.dataset.pictures) });

  imageUploaderRoot.render(<Provider store={window.picturesStore}><ImageUploader /></Provider>);

  pictureListRoot.render(<Provider store={window.picturesStore}><PictureList /></Provider>);
};

if (document.readyState === "complete") {
  setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
