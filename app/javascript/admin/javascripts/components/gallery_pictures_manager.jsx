import React, { useState, useCallback, useEffect, useRef } from "react";
import update from "immutability-helper";
import GalleryPicture from "./gallery_picture";

const GalleryPicturesManager = (props) => {
  const [galleryPictures, setGalleryPictures] = useState(() => props.galleryPictures.map((picture, index) => ({ ...picture, clientKey: index })));
  const nextClientKey = useRef(props.galleryPictures.length);
  const scrollToAddedPicture = useRef(false);

  useEffect(() => {
    if (scrollToAddedPicture.current) {
      document.querySelector(".gallery-picture:last-child")?.scrollIntoView({ behavior: "smooth", block: "nearest" });
      scrollToAddedPicture.current = false;
    }
  }, [galleryPictures]);

  const addGalleryPicture = (picture) => {
    const newGalleryPicture = {
      clientKey: nextClientKey.current++,
      data: {
        id: null,
        type: "gallery_picture",
        attributes: {
          gallery_id: null,
          picture_id: parseInt(picture.data.id),
          order: galleryPictures.length,
          visible: true,
          featured: false,
          created_at: null,
          updated_at: null,
          picture_original_image_url: picture.data.attributes.original_image_url,
          picture_medium_image_url: picture.data.attributes.medium_image_url,
          picture_thumbnail_image_url: picture.data.attributes.thumbnail_image_url,
        }
      }
    };

    scrollToAddedPicture.current = true;
    setGalleryPictures((pictures) => update(pictures, { $push: [newGalleryPicture] }));
  };

  const removeGalleryPicture = (index) => {
    setGalleryPictures(update(galleryPictures, { $splice: [[index, 1]] }));
  };

  // Temporary bridge while the nested gallery fields still belong to React.
  useEffect(() => {
    const select = (event) => addGalleryPicture(event.detail.picture);
    props.pictureSelector.addEventListener("picture-selector:select", select);
    props.pictureSelector.dataset.pictureSelectorReadyValue = "true";
    return () => {
      props.pictureSelector.removeEventListener("picture-selector:select", select);
      props.pictureSelector.dataset.pictureSelectorReadyValue = "false";
    };
  }, [props.pictureSelector, galleryPictures]);

  const moveGalleryPicture = useCallback((dragIndex, hoverIndex) => {
    const dragGalleryPicture = galleryPictures[dragIndex];

    setGalleryPictures(update(galleryPictures, {
      $splice: [
        [dragIndex, 1],
        [hoverIndex, 0, dragGalleryPicture]
      ]
    }).map((galleryPicture, order) => update(galleryPicture, { data: { attributes: { order: { $set: order } } } })));
  }, [galleryPictures]);

  const updateGalleryPicture = (index, attribute, value, exclusive = false) => {
    if (exclusive && value === true) {
      setGalleryPictures(galleryPictures.map((galleryPicture, i) => update(galleryPicture, { data: { attributes: { [attribute]: { $set: i === index } } } })));
    } else {
      const updatedGalleryPicture = update(galleryPictures[index], { data: { attributes: { [attribute]: { $set: value } } } });

      setGalleryPictures(update(galleryPictures, { [index]: { $set: updatedGalleryPicture } }));
    }
  };

  return (
    <div className="gallery-pictures-manager">
      {galleryPictures.map((galleryPicture, index) =>
                           <GalleryPicture
                             key={galleryPicture.clientKey}
                             index={index}
                             id={galleryPicture.data.id}
                             removeGalleryPicture={removeGalleryPicture}
                             moveGalleryPicture={moveGalleryPicture}
                             updateGalleryPicture={updateGalleryPicture}
                             {...galleryPicture.data.attributes}
                           />)}
    </div>
  );
};

export default GalleryPicturesManager;
