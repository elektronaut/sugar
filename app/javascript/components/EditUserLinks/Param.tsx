import React from "react";


interface ParamProps {
  position: number,
  userLink: UserLink.Link
}

export default function Param(props: ParamProps) {
  const { position, userLink } = props;

  const name = (property: string) => {
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
