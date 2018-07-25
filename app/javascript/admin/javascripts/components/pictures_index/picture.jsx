import React from "react";
import PropTypes from "prop-types";
import moment from "moment";

const Picture = ({ picture }) => (
  <div className="picture row">
    <div className="thumbnail col s3">
      <a href={`/admin/pictures/${picture.data.attributes.slug}`}>
        <img src={picture.data.attributes.original_image_url} className="thumb" style={{ "maxHeight": "50px" }} alt={picture.data.attributes.alt_text} title={picture.data.attributes.title} />
      </a>
    </div>
    <div className="title col s4">
      <a href={`/admin/pictures/${picture.data.attributes.slug}`}>
        {picture.data.attributes.title}
      </a>
    </div>
    <div className="created-at col s3">
      {moment(picture.data.attributes.created_at).format("Y-MM-DD HH:mm:ss")}
    </div>
    <div className="edit col s1">
      <a href={`/admin/pictures/${picture.data.attributes.slug}/edit`}>
        <i className="material-icons">edit</i>
      </a>
    </div>
    <div className="destroy col s1">
      <a href={`/admin/pictures/${picture.data.attributes.slug}`} data-method="delete" data-confirm="Are you sure?" rel="nofollow">
        <i className="material-icons">delete_forever</i>
      </a>
    </div>
  </div>
);

Picture.propTypes = {
  "picture": PropTypes.object.isRequired
};

export default Picture;
