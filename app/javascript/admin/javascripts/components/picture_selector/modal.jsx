import React from "react";
import PropTypes from "prop-types";
import Picture from "./modal/picture";

class Modal extends React.Component {
  render() {
    const pictures = this.props.pictures.map((picture) => {
      const onClick = (event) => {
        event.preventDefault();

        this.props.pictureOnClick(picture);
      };

      return (
        <Picture key={picture.data.id} picture={picture} onClick={onClick} />
      );
    });

    return (
      <div className="picture-selector-modal">
        <i className="picture-selector-close-button material-icons">close</i>
        <div className="picture-selector-modal-body">
          <div className="row picture-selector-modal-pictures">
            {pictures}
          </div>
        </div>
      </div>
    );
  }
}

export default Modal;
