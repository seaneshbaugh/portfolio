import React from "react";
import { render } from "react-dom";
import { DndProvider } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";
import GalleryPicturesManager from "../components/gallery_pictures_manager";

const completed = () => {
  const galleryPicturesContainer = document.querySelector(".gallery-pictures-container");

  if (!galleryPicturesContainer) {
    return;
  }

  const galleryPictures = JSON.parse(galleryPicturesContainer.dataset.gallerypictures);

  render(<DndProvider backend={HTML5Backend}><GalleryPicturesManager galleryPictures={galleryPictures} /></DndProvider>, galleryPicturesContainer);
};

if (document.readyState === "complete") {
  setTimeout(completed);
} else {
  document.addEventListener("DOMContentLoaded", completed, false);
}
