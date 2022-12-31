import React from "react";
import PropTypes from "prop-types";

function label(userLink) {
  return userLink.name || userLink.url.replace(/^(f|ht)tps?:\/\//, "");
}

export default function UserLink(props) {
  const { dispatch } = props;
  const userLink = props.userLink;

  const handleEdit = (evt) => {
    evt.preventDefault();
    dispatch({ type: "edit", payload: userLink });
  };

  const handleDelete = (evt) => {
    evt.preventDefault();
    dispatch({ type: "delete", payload: userLink });
  };

  return (
    <div className="user-link">
      <div className="info">
        <div className="label">
          {userLink.label}
        </div>
        <div className="link">
          {!userLink.url && label(userLink)}
          {userLink.url &&
           <a href={userLink.url}>{label(userLink)}</a>}
        </div>
      </div>
      <div className="buttons">
        <button type="button" onClick={handleEdit}>
          Edit
        </button>
        <button type="button" onClick={handleDelete}>
          Remove
        </button>
      </div>
    </div>
  );
}

UserLink.propTypes = {
  dispatch: PropTypes.func,
  labels: PropTypes.array,
  position: PropTypes.number,
  userLink: PropTypes.object
};
