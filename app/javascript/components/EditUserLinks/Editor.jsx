import React, { useState } from "react";
import PropTypes from "prop-types";

import TypeaheadTextField from "../Input/TypeaheadTextField";

function preventSubmit(evt) {
  if (evt.key === "Enter") {
    evt.preventDefault();
  }
}
export default function Editor(props) {
  const { dispatch, newLink } = props;

  const [userLink, setUserLink] = useState(props.userLink);

  const updateAttribute = (attr) => (value) => {
    setUserLink({ ...userLink, [attr]: value });
  };

  const handleChange = (attr) => (evt) => {
    updateAttribute(attr)(evt.target.value);
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
      <TypeaheadTextField
        label="Label"
        name="label"
        autoFocus={true}
        onChange={updateAttribute("label")}
        onKeyDown={preventSubmit}
        options={props.labels}
        size={40}
        value={userLink.label} />
      <div className="field">
        <label htmlFor="name">
          Name
          <div className="description">
            E.g. Link text, username, code or similar
          </div>
        </label>
        <input type="text"
               name="name"
               size={50}
               onChange={handleChange("name")}
               onKeyDown={preventSubmit}
               value={userLink.name} />
      </div>
      <div className="field">
        <label htmlFor="url">
          URL
        </label>
        <input type="text"
               name="url"
               size={50}
               onChange={handleChange("url")}
               onKeyDown={preventSubmit}
               value={userLink.url} />
      </div>
      <div className="buttons">
        <button type="button"
                onClick={handleSave}
                disabled={!validUserLink()}>
          {newLink ? "Add" : "Update"}
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
  newLink: PropTypes.bool,
  userLink: PropTypes.object
};