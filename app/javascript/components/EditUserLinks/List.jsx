import React from "react";
import PropTypes from "prop-types";

import UserLink from "./UserLink";

export default function List(props) {
  const { dispatch, userLinks } = props;

  return (
    <div className="list">
      {userLinks.map((ul, index) =>
        <UserLink key={ul.handle}
                  dispatch={dispatch}
                  userLink={ul}
                  position={index + 1} />)}
    </div>
  );
}

List.propTypes = {
  dispatch: PropTypes.func,
  userLinks: PropTypes.array
};
