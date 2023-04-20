import React from "react";

export default function Menu(props: { children: JSX.Element }) {
  return (
    <ul className="dropdown-menu"
        {...props}>
      {props.children}
    </ul>
  );
}
