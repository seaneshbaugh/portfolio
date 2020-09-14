import React, { useRef } from "react";
import { useDrag, useDrop } from "react-dnd";
import classNames from "classnames";
import Checkbox from "./checkbox";

const GalleryPicture = ({ index, id, picture_id, order, featured, visible, picture_thumbnail_image_url, _destroy, hidden, updateGalleryPicture, moveGalleryPicture, removeGalleryPicture }) => {
  const ref = useRef(null);

  const [, drop] = useDrop({
    accept: "GalleryPicture",
    hover(item, monitor) {
      if (!ref.current) {
        return;
      }

      const dragIndex = item.index;

      const hoverIndex = index;

      if (dragIndex === hoverIndex) {
        return;
      }

      const hoverBoundingRect = ref.current?.getBoundingClientRect();

      const hoverMiddleY = (hoverBoundingRect.bottom - hoverBoundingRect.top) / 2;

      const clientOffset = monitor.getClientOffset();

      const hoverClientY = clientOffset.y - hoverBoundingRect.top;

      if (dragIndex < hoverIndex && hoverClientY < hoverMiddleY) {
        return;
      }

      if (dragIndex > hoverIndex && hoverClientY > hoverMiddleY) {
        return;
      }

      moveGalleryPicture(dragIndex, hoverIndex);

      item.index = hoverIndex;
    }
  });

  const [{ isDragging }, drag] = useDrag({
    item: { type: "GalleryPicture", id, index },
    collect: (monitor) => ({
      isDragging: monitor.isDragging()
    })
  });

  const handleRemoveClick = (event) => {
    event.preventDefault();

    updateGalleryPicture(index, "_destroy", true);
  };

  const handleFeaturedChange = () => {
    updateGalleryPicture(index, "featured", !featured, true);
  };

  const handleVisibleChange = () => {
    updateGalleryPicture(index, "visible", !visible);
  };

  const doneFading = (event) => {
    if (id !== null) {
      updateGalleryPicture(index, "hidden", true);
    } else {
      removeGalleryPicture(index);
    }
  };

  const inputName = (attribute) => {
    return `gallery[gallery_pictures_attributes][${index}][${attribute}]`;
  };

  const inputId = (attribute) => {
    return `gallery_gallery_pictures_attributes_${index}_${attribute}`;
  };

  const className = classNames({
    "gallery-picture": true,
    "row": true,
    "dragging": isDragging,
    "animate__animated animate__fadeOutRight": _destroy,
    "hide": hidden
  });

  drag(drop(ref));

  return (
    <div ref={ref} className={className} onAnimationEnd={doneFading}>
      <button className="btn btn-flat waves-effect waves-light red lighten-1 right" onClick={handleRemoveClick}><i className="material-icons">delete_forever</i></button>
      {id &&
       <input type="hidden" name={inputName("id")} value={id} id={inputId("id")}></input>
      }
      <input type="hidden" name={inputName("picture_id")} value={picture_id} id={inputId("picture_id")}></input>
      <input type="hidden" name={inputName("_destroy")} value={_destroy ? "1" : "0"} id={inputId("_destroy")}></input>
      <img src={picture_thumbnail_image_url} />
      <input type="hidden" name={inputName("order")} value={order} id={inputId("order")}></input>
      <Checkbox name={inputName("featured")} id={inputId("featured")} checked={featured} onChange={handleFeaturedChange} labelText="Featured" />
      <Checkbox name={inputName("visible")} id={inputId("visible")} checked={visible} onChange={handleVisibleChange} labelText="Visible" />
    </div>
  );
};

export default GalleryPicture;
