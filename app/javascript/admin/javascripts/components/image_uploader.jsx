import React from "react";
import { connect } from "react-redux";
import PropTypes from "prop-types";
import classNames from "classnames";
import { DirectUpload } from "@rails/activestorage";
import { addPicture } from "../actions/pictures_actions";

let fileInputId = 0;

const getFileInputId = () => (fileInputId += 1);

class ImageUploader extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      "border": "dotted",
      "csrf_param": document.querySelector("meta[name='csrf-param']").content,
      "csrf_token": document.querySelector("meta[name='csrf-token']").content
    };

    this.handleDragEnter = this.handleDragEnter.bind(this);
    this.handleDragOver = this.handleDragOver.bind(this);
    this.handleDragExit = this.handleDragExit.bind(this);
    this.handleDrop = this.handleDrop.bind(this);
  }

  UNSAFE_componentWillMount() {
    const x = `image-uploader-file-input-${getFileInputId()}`;
    console.log(x);
    this.setState({ "fileInputId": x });
  }

  handleDragEnter() {
    this.setState({ "border": "solid" });
  }

  handleDragOver(event) {
    event.preventDefault();
  }

  handleDragExit() {
    this.setState({ "border": "dotted" });
  }

  handleDrop(event) {
    event.preventDefault();
    event.stopPropagation();
    this.setState({ "border": "dotted" });
    const files = event.dataTransfer.files;
    Array.from(files).forEach(file => this.uploadFile(file));
  }

  uploadFile(file) {
    const url = "/rails/active_storage/direct_uploads";
    const upload = new DirectUpload(file, url);

    // TODO: Figure out the scoping of the below blocks, somewhere this is
    // being lost. For now this will do.
    const addPicture = this.props.addPicture;

    upload.create((error, blob) => {
      if (error) {
        // TODO: Handle the error.
      } else {
        const action = "/admin/pictures";

        const params = {
          "utf8": "✓",
          "picture": {
            "image": blob.signed_id
          }
        };

        params[this.state.csrf_param] = this.state.csrf_token;

        window.fetch(action, {
          "method": "POST",
          "headers": {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          "body": JSON.stringify(params)
        }).then((response) => {
          return response.json();
        }).then((json) => {
          addPicture(json);
        });
      }
    });
  }

  render() {
    const imageUploaderClassName = classNames({
      "image-uploader": true,
      "hover": this.state.hover
    });

    const imageUploaderEventHandlers = {
      "onDragEnter": this.handleDragEnter,
      "onDragOver": this.handleDragOver,
      "onDragExit": this.handleDragExit,
      "onDrop": this.handleDrop
    };

    return (
      <div className={imageUploaderClassName} {...imageUploaderEventHandlers}>
        <input type="file" id={this.state.fileInputId} />
        <label htmlFor={this.state.fileInputId}>Drop Images Here</label>
      </div>
    );
  }
}

ImageUploader.propTypes = {
  "addPicture": PropTypes.func.isRequired
};

const mapStateToProps = (state) => ({});

const mapDispatchToProps = (dispatch) => ({
  "addPicture": (picture) => (dispatch(addPicture(picture)))
});

export default connect(mapStateToProps, mapDispatchToProps)(ImageUploader);
