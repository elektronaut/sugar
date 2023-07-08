interface PostAttributes {
  id: number;
  user_id: number;
  exchange_type: string;
  exchange_id?: number;
}

interface UserAttributes {
  id: number;
  username: string;
  admin: boolean;
  moderator: boolean;
}

interface PostingStatusEvent extends CustomEvent {
  detail: string;
}

interface PostsLoadedEvent extends CustomEvent {
  detail: HTMLElement[];
}
