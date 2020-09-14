import React from "react";
import PropTypes from "prop-types";
import moment from "moment";

const Picture = ({ picture }) => (
  <tr className="picture">
    <td className="picture thumbnail">
      <a href={`/admin/pictures/${picture.data.attributes.slug}`}>
        <img src={picture.data.attributes.thumbnail_image_url} alt={picture.data.attributes.alt_text} title={picture.data.attributes.title} />
      </a>
    </td>
    <td className="picture-title">
      <a href={`/admin/pictures/${picture.data.attributes.slug}`}>
        {picture.data.attributes.title}
      </a>
    </td>
    <td className="picture-created-at">
      {moment(picture.data.attributes.created_at).format("Y-MM-DD HH:mm:ss")}
    </td>
    <td className="edit">
      <a href={`/admin/pictures/${picture.data.attributes.slug}/edit`}>
        <i className="material-icons">edit</i>
      </a>
    </td>
    <td className="delete">
      <a href={`/admin/pictures/${picture.data.attributes.slug}`} data-method="delete" data-confirm="Are you sure you wish to delete this?" rel="nofollow">
        <i className="material-icons">delete_forever</i>
      </a>
    </td>
  </tr>
);

Picture.propTypes = {
  "picture": PropTypes.shape({
    "data": PropTypes.shape({
      "id": PropTypes.string,
      "type": PropTypes.string,
      "attributes": PropTypes.shape({
        "slug": PropTypes.string.isRequired,
        "title": PropTypes.string.isRequired,
        "alt_text": PropTypes.string.isRequired,
        "caption": PropTypes.string,
        "original_image_url": PropTypes.string,
        "original_image_path": PropTypes.string,
        "medium_image_path": PropTypes.string,
        "medium_image_url": PropTypes.string,
        "thumbnail_image_path": PropTypes.string,
        "thumbnail_image_url": PropTypes.string.isRequired,
        "created_at": PropTypes.string.isRequired,
        "updated_at": PropTypes.string
      })
    }).isRequired
  }).isRequired
};

export default Picture;
