import React from "react";
import PropTypes from "prop-types";
import Button from "./picture_selector/button";
import Modal from "./picture_selector/modal";

class PictureSelector extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      "modalOpen": false
    };

    this.openModal = this.openModal.bind(this);
    this.closeModal = this.closeModal.bind(this);
    this.insertPicture = this.insertPicture.bind(this);
  }

  openModal(event) {
    event.preventDefault();

    window.fetch("/admin/pictures", {
      "headers": {
        "Accept": "application/json",
        "Content-Type": "application/json"
      }
    }).then((response) => {
      return response.json();
    }).then((json) => {
      this.setState({
        "modalOpen": true,
        "pictures": json
      });
    });
  }

  closeModal(event) {
    event.preventDefault();

    this.setState({
      "modalOpen": false
    });
  }

  insertPicture(picture) {
    console.log(`#${this.props.target} .ace-editor`);
    const editor = document.querySelector(`#${this.props.target} .ace_editor`).env.editor;

    let image = `<img src="${picture.data.attributes.original_image_url}"`;

    if (picture.data.attributes.alt_text) {
      image += ` alt=${picture.data.attributes.alt_text}"`;
    }

    image += ">";

    editor.insert(image);

    this.setState({
      "modalOpen": false
    });
  }

  render() {
    let modal = null;
    let overlay = null;

    if (this.state.modalOpen) {
      modal = <Modal pictures={this.state.pictures} pictureOnClick={this.insertPicture} />;
      overlay = <div className="picture-selector-modal-overlay" onClick={this.closeModal}></div>;
    }

    return(
      <div className="picture-selector">
        <Button className={this.props.buttonClassName} text={this.props.buttonText} onClick={this.openModal} />
        {overlay}
        {modal}
      </div>
    );
  }
}

PictureSelector.propTypes = {
  "buttonClassName": PropTypes.string,
  "buttonText": PropTypes.string,
  "target": PropTypes.string.isRequired
};

export default PictureSelector;
