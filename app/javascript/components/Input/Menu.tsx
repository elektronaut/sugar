import React from "react";

type Props = {
  children: React.ReactNode;
};

export default function Menu(props: Props) {
  return (
    <ul className="dropdown-menu" {...props}>
      {props.children}
    </ul>
  );
}
