import React from "react";
import { connect } from "react-redux";
import PropTypes from "prop-types";

import Picture from "./picture";

const PictureList = ({ pictures }) => (
  <div className="pictures-list">
    {pictures.map((picture, index) => (
      <Picture key={index} picture={picture} />
    ))}
  </div>
);

PictureList.propTypes = {
  "pictures": PropTypes.arrayOf(PropTypes.object).isRequired
};

const mapStateToProps = (state) => ({
  "pictures": state.pictures
});

const mapDispatchToProps = (dispatch) => ({});

export default connect(mapStateToProps, mapDispatchToProps)(PictureList);
