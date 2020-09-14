import React from "react";
import PropTypes from "prop-types";

class Picture extends React.Component {
  constructor(props) {
    super(props);

    this.handleClick = this.props.onClick.bind(this);
  }

  render() {
    return(
      <div className="picture-selector-modal-picture col s4" onClick={this.handleClick}>
        <img src={this.props.picture.data.attributes.thumbnail_image_url} alt={this.props.picture.data.attributes.alt_text} />
        <span className="title">{this.props.picture.data.attributes.title}</span>
      </div>
    );
  }
}

Picture.propTypes = {
  "onClick": PropTypes.func.isRequired,
  "picture": PropTypes.shape({
    "data": PropTypes.shape({
      "id": PropTypes.string,
      "type": PropTypes.string,
      "attributes": PropTypes.shape({
        "slug": PropTypes.string,
        "title": PropTypes.string.isRequired,
        "alt_text": PropTypes.string.isRequired,
        "caption": PropTypes.string,
        "original_image_url": PropTypes.string,
        "medium_image_path": PropTypes.string,
        "thumbnail_image_url": PropTypes.string.isRequired,
        "created_at": PropTypes.string,
        "updated_at": PropTypes.string
      })
    }).isRequired
  }).isRequired
};

export default Picture;
