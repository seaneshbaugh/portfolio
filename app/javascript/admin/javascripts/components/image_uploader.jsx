import React from "react";
import { connect } from "react-redux";
import PropTypes from "prop-types";
import classNames from "classnames";
import { DirectUpload } from "@rails/activestorage";
import { addPicture } from "../actions/pictures_actions";

let fileInputId = 0;

class ImageUploader extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hover: false, pending: 0, errors: [] };
    this.fileInputId = `image-uploader-file-input-${++fileInputId}`;
    this.handleDrop = this.handleDrop.bind(this);
    this.handleFileChange = this.handleFileChange.bind(this);
  }

  handleFileChange(event) {
    const files = Array.from(event.target.files);
    event.target.value = "";
    files.forEach((file) => this.uploadFile(file));
  }

  handleDrop(event) {
    event.preventDefault();
    event.stopPropagation();
    this.setState({ hover: false });
    Array.from(event.dataTransfer.files).forEach((file) => this.uploadFile(file));
  }

  async uploadFile(file) {
    if (!file.type.startsWith("image/")) {
      this.setState((state) => ({ errors: [...state.errors, `${file.name}: Please choose an image.`] }));
      return;
    }

    this.setState((state) => ({ pending: state.pending + 1 }));
    try {
      const blob = await new Promise((resolve, reject) => {
        new DirectUpload(file, "/rails/active_storage/direct_uploads").create((error, result) => {
          if (error) reject(new Error("Unable to upload the image. Please try again."));
          else resolve(result);
        });
      });
      const response = await window.fetch("/admin/pictures", {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        },
        body: JSON.stringify({ picture: { image: blob.signed_id } })
      });
      if (!response.headers.get("Content-Type")?.includes("application/json")) {
        throw new Error("Unable to save the picture. Please try again.");
      }
      const json = await response.json();
      if (!response.ok || json.errors) {
        throw new Error(json.errors?.map((error) => error.title).join(". ") || "Unable to save the picture. Please try again.");
      }
      this.props.addPicture(json);
    } catch (error) {
      const message = error instanceof TypeError || error instanceof SyntaxError ? "Upload failed. Please try again." : error.message;
      this.setState((state) => ({ errors: [...state.errors, `${file.name}: ${message}`] }));
    } finally {
      this.setState((state) => ({ pending: state.pending - 1 }));
    }
  }

  render() {
    return (
      <div
        className={classNames({ "image-uploader": true, "hover": this.state.hover })}
        onDragEnter={(event) => { event.preventDefault(); this.setState({ hover: true }); }}
        onDragOver={(event) => event.preventDefault()}
        onDragLeave={(event) => {
          if (!event.currentTarget.contains(event.relatedTarget)) this.setState({ hover: false });
        }}
        onDrop={this.handleDrop}
      >
        <input type="file" id={this.fileInputId} multiple accept="image/*" onChange={this.handleFileChange} />
        <label htmlFor={this.fileInputId}>Drop images here or choose files</label>
        {this.state.pending > 0 && <p role="status">Uploading…</p>}
        {this.state.errors.length > 0 && <ul role="alert">{this.state.errors.map((error, index) => <li key={index}>{error}</li>)}</ul>}
      </div>
    );
  }
}

ImageUploader.propTypes = { "addPicture": PropTypes.func.isRequired };
const mapDispatchToProps = (dispatch) => ({ "addPicture": (picture) => dispatch(addPicture(picture)) });
export default connect(null, mapDispatchToProps)(ImageUploader);
