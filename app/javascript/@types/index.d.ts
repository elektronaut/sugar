type PostAttributes = {
  id: number;
  user_id: number;
  exchange_type: string;
  exchange_id?: number;
};

type UserAttributes = {
  id: number;
  username: string;
  admin: boolean;
  moderator: boolean;
};

type NewPostsEvent = CustomEvent & {
  detail: {
    total: number;
    newPosts: number;
    unread: number;
  };
};

type PostingStatusEvent = CustomEvent & {
  detail: string;
};

type PostsLoadedEvent = CustomEvent & {
  detail: HTMLElement[];
};

type QuoteEvent = CustomEvent & {
  detail: {
    username: string;
    permalink: string;
    html: string;
  };
};
