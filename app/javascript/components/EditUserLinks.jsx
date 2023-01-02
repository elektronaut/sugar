import React from "react";
import PropTypes from "prop-types";

import useUserLinks from "./EditUserLinks/useUserLinks";
import Editor from "./EditUserLinks/Editor";
import List from "./EditUserLinks/List";
import Param from "./EditUserLinks/Param";

export default function EditUserLinks(props) {
  const [state, dispatch] = useUserLinks(props.userLinks);

  const enabledLinks = state.userLinks.filter(ul => !ul.deleted);

  const handleAdd = (evt) => {
    evt.preventDefault();
    dispatch({ type: "add" });
  };

  return (
    <div className="edit-user-links">
      {state.editing &&
       <Editor dispatch={dispatch}
               labels={props.labels}
               newLink={enabledLinks.indexOf(state.editing) == -1}
               userLink={state.editing} />}
      {!state.editing &&
       <React.Fragment>
         <List dispatch={dispatch}
               userLinks={enabledLinks} />
         <div className="buttons">
           <button type="button"
                   onClick={handleAdd}>
             Add link
           </button>
         </div>
       </React.Fragment>}
      {state.userLinks.map((ul, i) =>
        <Param key={ul.handle}
               userLink={ul}
               position={i + 1} />)}
    </div>
  );
}

EditUserLinks.propTypes = {
  labels: PropTypes.array,
  userLinks: PropTypes.array
};
