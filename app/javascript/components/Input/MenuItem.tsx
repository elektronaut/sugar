interface Props {
  isActive: boolean;
  isSelected: boolean;
  children: React.ReactNode;
}

export default function MenuItem(props: Props) {
  const classNames = [];
  if (props.isActive) {
    classNames.push("active");
  }
  if (props.isSelected) {
    classNames.push("selected");
  }

  return (
    <li className={classNames.join(" ")} {...props}>
      {props.children}
    </li>
  );
}
