import React from "react";

interface MenuItemProps {
  item: string,
  index: number,
  isActive: boolean,
  isSelected: boolean,
  children: JSX.Element
}

export default function MenuItem(props: MenuItemProps) {
  const classNames = [];
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
