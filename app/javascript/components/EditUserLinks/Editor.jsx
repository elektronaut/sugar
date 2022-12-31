import React, { useState } from "react";
import PropTypes from "prop-types";

export default function Editor(props) {
  const { dispatch } = props;

  const [userLink, setUserLink] = useState(props.userLink);

  const handleChange = (attr) => (evt) => {
    setUserLink({ ...userLink, [attr]: evt.target.value });
  };

  const handleCancel = (evt) => {
    evt.preventDefault();
    dispatch({ type: "cancel" });
  };

  const handleSave = (evt) => {
    evt.preventDefault();
    dispatch({ type: "save", payload: userLink });
  };

  const validUserLink = () => {
    const urlPattern = /^(https?:\/\/)?[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}/;
    if (userLink.url && !userLink.url.match(urlPattern)) {
      return false;
    }
    return userLink.label && (userLink.name || userLink.url);
  };

  return (
    <div className="editor">
      <div className="field">
        <label>Label</label>
        <input type="text"
               name="label"
               size={50}
               onChange={handleChange("label")}
               value={userLink.label} />
      </div>
      <div className="field">
        <label>Name</label>
        <input type="text"
               name="name"
               size={50}
               onChange={handleChange("name")}
               value={userLink.name} />
      </div>
      <div className="field">
        <label>URL</label>
        <input type="text"
               name="url"
               size={50}
               onChange={handleChange("url")}
               value={userLink.url} />
      </div>
      <div className="buttons">
        <button type="button"
                onClick={handleSave}
                disabled={!validUserLink()}>
          Save
        </button>
        <button type="button" onClick={handleCancel}>
          Cancel
        </button>
      </div>
    </div>
  );
}

Editor.propTypes = {
  dispatch: PropTypes.func,
  labels: PropTypes.array,
  userLink: PropTypes.object
};
