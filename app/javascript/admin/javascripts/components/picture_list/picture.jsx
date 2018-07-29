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
  "picture": PropTypes.object.isRequired
};

export default Picture;
