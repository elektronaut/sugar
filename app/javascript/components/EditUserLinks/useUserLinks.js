import { useReducer } from "react";
import { v4 as uuidv4 } from "uuid";

function updateLink(state, link) {
  return { ...state,
           userLinks: state.userLinks.map(ul => {
             if (ul.handle === link.handle) {
               return link;
             } else {
               return ul;
             }
           }) };
}

function newUserLink() {
  return({ id: null, label: "", name: "", url: "",
           deleted: false, handle: uuidv4() });
}

function saveUserLink(state, userLink) {
  let userLinks = state.userLinks;
  if (userLinks.filter(a => a.handle == userLink.handle).length > 0) {
    userLinks = userLinks.map(a => {
      if (a.handle == userLink.handle) {
        return userLink;
      } else {
        return a;
      }
    });
  } else {
    userLinks = userLinks.concat({ ...userLink, new: false });
  }
  return { ...state, userLinks: userLinks, editing: null };
}

function reducer(state, action) {
  switch (action.type) {
  case "add":
    return { ...state, editing: newUserLink() };
  case "cancel":
    return { ...state, editing: null };
  case "delete":
    if (action.payload.id) {
      return updateLink(state, { ...action.payload, deleted: true });
    } else {
      return {
        ...state,
        userLinks: state.userLinks.filter(ul => ul.handle !== action.payload.handle)
      };
    }
  case "edit":
    return { ...state, editing: action.payload };
  case "reorder":
    return { ...state, userLinks: action.payload };
  case "save":
    return saveUserLink(state, action.payload);
  case "update":
    return updateLink(state, action.payload);
  default:
    return state;
  }
}

function createInitialState(userLinks) {
  return {
    editing: null,
    userLinks: userLinks.map(ul => {
      return { ...ul, deleted: false, handle: uuidv4() };
    })
  };
}

function ensureDeletedLastReducer(state, action) {
  const nextState = reducer(state, action);
  return { ...nextState,
           userLinks: [...nextState.userLinks.filter(l => !l.deleted),
                       ...nextState.userLinks.filter(l => l.deleted)] };
}

export default function useUserLinks(userLinks) {
  const [state, dispatch] =
        useReducer(ensureDeletedLastReducer, userLinks, createInitialState);
  return [state, dispatch];
}
