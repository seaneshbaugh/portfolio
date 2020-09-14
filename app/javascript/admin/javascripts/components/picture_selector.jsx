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
    this.handleSelect = this.handleSelect.bind(this);
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

  handleSelect(picture) {
    this.props.onSelect(picture);

    this.setState({
      "modalOpen": false
    });
  }

  render() {
    let modal = null;
    let overlay = null;

    if (this.state.modalOpen) {
      modal = <Modal pictures={this.state.pictures} pictureOnClick={this.handleSelect} />;
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
  "onSelect": PropTypes.func.isRequired
};

export default PictureSelector;
