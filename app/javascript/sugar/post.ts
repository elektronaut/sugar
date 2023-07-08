import functions from "./post/functions.ts";
import mute from "./post/mute.ts";
import spoiler from "./post/spoiler.ts";

const postsSelector =
  "body.discussion div.posts, " +
  "body.search div.posts, " +
  "body.user_profile div.posts";

function renderPost(elem: HTMLElement) {
  functions(elem);
  mute(elem);
  spoiler(elem);
}

export function startPosts() {
  document.addEventListener("postsloaded", (event: PostsLoadedEvent) => {
    event.detail.forEach((post) => renderPost(post));
  });

  document.querySelectorAll(postsSelector).forEach((elem) => {
    const posts = [...elem.querySelectorAll(".post")];
    document.dispatchEvent(
      new CustomEvent("postsloaded", {
        detail: posts
      })
    );
  });
}
