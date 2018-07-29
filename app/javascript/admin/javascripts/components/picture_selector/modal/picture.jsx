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

export default Picture;
