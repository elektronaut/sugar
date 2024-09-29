import User from "./User";

const defaultAttributes = {
  exchange_type: "Exchange"
};

export default class Post {
  attributes: Partial<PostAttributes>;

  constructor(attrs: Partial<PostAttributes>) {
    this.attributes = { ...defaultAttributes, ...attrs };
  }

  editableBy = (user: User) => {
    if (user && (user.id === this.attributes.user_id || user.isModerator())) {
      return true;
    } else {
      return false;
    }
  };

  editUrl = () => {
    return `${this.url()}/edit?${new Date().getTime()}`;
  };

  url = () => {
    let base = "";

    if (this.attributes.exchange_id && this.attributes.exchange_type) {
      base =
        "/" +
        this.attributes.exchange_type.toLowerCase() +
        `s/${this.attributes.exchange_id}`;
    }

    return `${base}/posts/${this.attributes.id}`;
  };
}
