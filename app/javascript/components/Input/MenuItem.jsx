import React from "react";
import PropTypes from "prop-types";

export default function MenuItem(props) {
  let classNames = [];
  if (props.isActive) {
    classNames.push("active");
  }
  if (props.isSelected) {
    classNames.push("selected");
  }

  return (
    <li className={classNames.join(" ")}
        {...props}>
      {props.children}
    </li>
  );
}

MenuItem.propTypes = {
  item: PropTypes.string,
  index: PropTypes.number,
  isActive: PropTypes.bool,
  isSelected: PropTypes.bool,
  children: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.object,
    PropTypes.array
  ])
};
