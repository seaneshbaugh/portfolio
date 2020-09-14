import React from "react";
import { render } from "react-dom";
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

  window.picturesStore = createStore(picturesReducer, { "pictures": JSON.parse(pictureListContainer.dataset.pictures) });

  render(<Provider store={window.picturesStore}><ImageUploader /></Provider>, imageUploaderContainer);

  render(<Provider store={window.picturesStore}><PictureList /></Provider>, pictureListContainer);
};

if (document.readyState === "complete") {
  setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
