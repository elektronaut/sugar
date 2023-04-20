import React from "react";
import { useSortable } from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";

import { UserLink as UserLinkRecord, UserLinksAction } from "./useUserLinks";

interface UserLinkProps {
  dispatch: (action: UserLinksAction) => void,
  labels: string[],
  position: number,
  userLink: UserLinkRecord
}

function label(userLink: UserLinkRecord) {
  return userLink.name || userLink.url.replace(/^(f|ht)tps?:\/\//, "");
}

export default function UserLink(props: UserLinkProps) {
  const { dispatch, userLink } = props;

  const { attributes,
          isDragging,
          listeners,
          setNodeRef,
          transform,
          transition } = useSortable({ id: userLink.handle });

  const style = { transform: CSS.Transform.toString(transform),
                  transition };

  const handleEdit = (evt: Event) => {
    evt.preventDefault();
    dispatch({ type: "edit", payload: userLink });
  };

  const handleDelete = (evt: Event) => {
    evt.preventDefault();
    dispatch({ type: "delete", payload: userLink });
  };

  const classNames = ["user-link"];
  if (isDragging) {
    classNames.push("dragging");
  }

  return (
    <div className={classNames.join(" ")}
         ref={setNodeRef}
         style={style}
         {...attributes}>
      <div className="drag-handle" {...listeners}>
        <i className="fa-solid fa-grip-lines"></i>
      </div>
      <div className="info">
        <div className="label">
          {userLink.label}
        </div>
        <div className="link">
          {!userLink.url && label(userLink)}
          {userLink.url &&
           <a href={userLink.url}>{label(userLink)}</a>}
        </div>
      </div>
      {!isDragging &&
       <div className="buttons">
         <button type="button" onClick={handleEdit}>
           Edit
         </button>
         <button type="button" onClick={handleDelete}>
           Remove
         </button>
       </div>}
    </div>
  );
}
