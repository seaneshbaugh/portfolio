import React from "react";
import PropTypes from "prop-types";
import Button from "./picture_selector/button";
import Modal from "./picture_selector/modal";

class PictureSelector extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      "modalOpen": false,
      "loading": false,
      "error": null
    };

    this.openModal = this.openModal.bind(this);
    this.closeModal = this.closeModal.bind(this);
    this.handleSelect = this.handleSelect.bind(this);
    this.handleKeyDown = this.handleKeyDown.bind(this);
  }

  componentDidMount() {
    document.addEventListener("keydown", this.handleKeyDown);
  }

  componentWillUnmount() {
    document.removeEventListener("keydown", this.handleKeyDown);
  }

  handleKeyDown(event) {
    if (event.key === "Escape" && this.state.modalOpen) this.closeModal(event);
  }

  openModal(event) {
    event.preventDefault();
    this.setState({ loading: true, error: null });

    window.fetch("/admin/pictures", {
      "headers": {
        "Accept": "application/json",
        "Content-Type": "application/json"
      }
    }).then((response) => {
      if (!response.ok) throw new Error("Unable to load pictures. Please try again.");
      return response.json();
    }).then((json) => {
      this.setState({
        "modalOpen": true,
        "pictures": json,
        "loading": false
      });
    }).catch((error) => {
      this.setState({ loading: false, error: error.message });
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
      modal = <Modal pictures={this.state.pictures} pictureOnClick={this.handleSelect} onClose={this.closeModal} />;
      overlay = <div className="picture-selector-modal-overlay" onClick={this.closeModal}></div>;
    }

    return(
      <div className="picture-selector">
        <Button className={this.props.buttonClassName} text={this.props.buttonText} disabled={this.state.loading} onClick={this.openModal} />
        {this.state.error && <p role="alert">{this.state.error}</p>}
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
