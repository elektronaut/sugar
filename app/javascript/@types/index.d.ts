interface PostingStatusEvent extends CustomEvent {
  detail: string;
}

interface PostsLoadedEvent extends CustomEvent {
  detail: HTMLElement[];
}
