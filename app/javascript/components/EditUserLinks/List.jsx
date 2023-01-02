import React from "react";
import PropTypes from "prop-types";
import {
  DndContext,
  closestCenter,
  PointerSensor,
  useSensor,
  useSensors,
} from "@dnd-kit/core";
import {
  arrayMove,
  SortableContext,
  verticalListSortingStrategy,
} from "@dnd-kit/sortable";

import UserLink from "./UserLink";

export default function List(props) {
  const { dispatch, userLinks } = props;

  const sensors = useSensors(useSensor(PointerSensor));

  const handleDragEnd = (evt) => {
    const { active, over } = evt;

    if (active.id !== over.id) {
      const ids = userLinks.map(o => o.handle);
      const oldIndex = ids.indexOf(active.id);
      const newIndex = ids.indexOf(over.id);
      props.dispatch({
        type: "reorder",
        payload: arrayMove(userLinks, oldIndex, newIndex)
      });
    }
  };

  return (
    <div className="list">
      <DndContext sensors={sensors}
                  collisionDetection={closestCenter}
                  onDragEnd={handleDragEnd}>
        <SortableContext items={userLinks.map(ul => ul.handle)}
                         strategy={verticalListSortingStrategy}>
          {userLinks.map((ul, index) =>
            <UserLink key={ul.handle}
                      dispatch={dispatch}
                      userLink={ul}
                      position={index + 1} />)}
        </SortableContext>
      </DndContext>
    </div>
  );
}

List.propTypes = {
  dispatch: PropTypes.func,
  userLinks: PropTypes.array
};
