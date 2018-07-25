import React from "react";
import { render } from "react-dom";
import { createStore } from "redux";
import { Provider } from "react-redux";

import picturesReducer from "../reducers/pictures_reducer";
import ImageUploader from "../components/image_uploader";
import PictureList from "../components/pictures_index/picture_list";

const completed = () => {
  window.picturesStore = createStore(picturesReducer, { "pictures": JSON.parse(document.querySelector(".picture-list-container").dataset.pictures) });

  Array.from(document.querySelectorAll(".image-uploader-container")).forEach((imageUploader, index) => {
    render(<Provider store={window.picturesStore}><ImageUploader /></Provider>, imageUploader);
  });

  Array.from(document.querySelectorAll(".picture-list-container")).forEach((pictureList, index) => {
    render(<Provider store={window.picturesStore}><PictureList /></Provider>, pictureList);
  });
};

if (document.readyState === "complete") {
  setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
