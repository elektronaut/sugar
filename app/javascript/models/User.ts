import Sugar from "../sugar";

interface IUser {
  id: number;
  attributes: UserAttributes;
}

export default class User implements IUser {
  id: number;
  attributes: UserAttributes;

  constructor(attrs: UserAttributes) {
    this.id = attrs.id;
    this.attributes = attrs;
  }

  isAdmin = () => {
    return this.attributes.admin;
  };

  isModerator = () => {
    return this.attributes.moderator || this.isAdmin();
  };
}

export function currentUser() {
  if (Sugar.Configuration.currentUser) {
    return new User(Sugar.Configuration.currentUser);
  } else {
    return null;
  }
}
