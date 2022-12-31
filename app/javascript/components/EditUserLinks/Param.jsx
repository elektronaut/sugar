import React from "react";
import PropTypes from "prop-types";

export default function Param(props) {
  const { position, userLink } = props;

  const name = (property) => {
    return `user[user_links_attributes][${position}][${property}]`;
  };

  if (!userLink.deleted) {
    return(
      <React.Fragment>
        <input name={name("id")} type="hidden" value={userLink.id} />
        <input name={name("position")} type="hidden" value={position} />
        <input name={name("label")} type="hidden" value={userLink.label} />
        <input name={name("name")} type="hidden" value={userLink.name} />
        <input name={name("url")} type="hidden" value={userLink.url} />
      </React.Fragment>
    );
  } else {
    return(
      <React.Fragment>
        <input name={name("id")} type="hidden" value={userLink.id} />
        <input name={name("_destroy")} type="hidden" value={true} />
      </React.Fragment>
    );
  }
}

Param.propTypes = {
  position: PropTypes.number,
  userLink: PropTypes.object
};
