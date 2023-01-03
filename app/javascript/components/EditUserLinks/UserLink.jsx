import React from "react";
import PropTypes from "prop-types";
import { useSortable } from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";

function label(userLink) {
  return userLink.name || userLink.url.replace(/^(f|ht)tps?:\/\//, "");
}

export default function UserLink(props) {
  const { dispatch, userLink } = props;

  const { attributes,
          isDragging,
          listeners,
          setNodeRef,
          transform,
          transition } = useSortable({ id: userLink.handle });

  const style = { transform: CSS.Transform.toString(transform),
                  transition };

  const handleEdit = (evt) => {
    evt.preventDefault();
    dispatch({ type: "edit", payload: userLink });
  };

  const handleDelete = (evt) => {
    evt.preventDefault();
    dispatch({ type: "delete", payload: userLink });
  };

  let classNames = ["user-link"];
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

UserLink.propTypes = {
  dispatch: PropTypes.func,
  labels: PropTypes.array,
  position: PropTypes.number,
  userLink: PropTypes.object
};
