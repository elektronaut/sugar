import React from "react";
import PropTypes from "prop-types";

export default function Menu(props) {
  return (
    <ul className="dropdown-menu"
        {...props}>
      {props.children}
    </ul>
  );
}

Menu.propTypes = {
  children: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.object,
    PropTypes.array
  ])
};
