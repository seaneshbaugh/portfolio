import React from "react";
import { connect } from "react-redux";
import PropTypes from "prop-types";

import Picture from "./picture_list/picture";

// TODO: Fix "key={index}". This is an anti-pattern.
const PictureList = ({ pictures }) => (
  <table className="pictures responsive-table">
    <thead>
      <tr>
        <th className="picture-thumbnail">Thumbnail</th>
        <th className="picture-title">Title</th>
        <th className="picture-created-at">Created At</th>
        <th className="edit"></th>
        <th className="delete"></th>
      </tr>
    </thead>
    <tbody>
      {pictures.slice(0, 25).map((picture, index) => (<Picture key={index} picture={picture} />))}
    </tbody>
  </table>
);

PictureList.propTypes = {
  "pictures": PropTypes.arrayOf(PropTypes.object).isRequired
};

const mapStateToProps = (state) => ({
  "pictures": state.pictures
});

const mapDispatchToProps = (dispatch) => ({});

export default connect(mapStateToProps, mapDispatchToProps)(PictureList);
