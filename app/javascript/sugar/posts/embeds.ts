import $ from "jquery";
import Sugar from "../../sugar";
import handleMastodonEmbeds from "./handleMastodonEmbeds";

interface PostCache {
  height: number,
  order: number
}

interface Cache {
  posts: Record<number, PostCache>,
  anchorPostId: number,
  anchorPostOrder: number,
  scrollY: number
}

interface Twitter {
  widgets: { load: (elem: HTMLElement) => void }
}

/**
 * Handlers for scripted embed (social) quirks
 */
$(Sugar).bind("ready", function(){

  // Fix for misbehaving or missing scroll anchoring
  const postsPage = document.querySelector(".posts");
  if (postsPage) {
    /**
     * Retrieved a post ID from a string which may
     * include a "post-" prefix.
     * @param {string} idString
     * @returns {number}
     */
    const parsePostIdString = (idString: string): number => {
      const idNum = idString.match(/(post-)?(\d+)/i);
      if (idNum && idNum.length) {
        return parseInt(idNum[2]);
      }
      return 0;
    };

    /**
     * Retrieve a post ID from its node, handling mobile
     * template and potential changes
     * @param {Element} post
     * @returns {number}
     */
    const getPostId = (post: HTMLElement) => {
      let postId = 0;
      if (post.dataset.post_id) {
        postId = parseInt(post.dataset.post_id);
      } else if (post.id.includes("post-")) {
        postId = parsePostIdString(post.id);
      } else {
        const anchor = post.querySelector(".anchor");
        if (anchor) {
          const anchorName = anchor.getAttribute("name");
          if (anchorName) {
            postId = parsePostIdString(anchorName);
          }
        }
      }
      return postId;
    };

    const cache: Cache = {
      posts: {},
      anchorPostId: parsePostIdString(window.location.hash),
      anchorPostOrder: 0,
      scrollY: window.scrollY
    };

    const resizeObserver = new ResizeObserver((posts) => {
      posts.forEach((post) => {
        const postId = getPostId(post.target);
        const pCache = cache.posts[postId];

        // Do not act on posts after or including our anchor
        if (!pCache || pCache.order >= cache.anchorPostOrder) {
          return;
        }

        // Prevent editing from triggering scroll
        const pBody = post.target.querySelector(".body");
        if (!pBody || pBody.offsetHeight < 1) {
          return;
        }

        let boxSize = pCache.height;
        if (post.borderBoxSize && post.borderBoxSize.length) {
          boxSize = post.borderBoxSize[0].blockSize;
        } else {
          boxSize = post.contentRect.height;
        }

        const offset = boxSize - pCache.height;

        if (cache.scrollY !== window.scrollY) {
          // Chrome updates the scroll position, but not the scroll!
          window.scrollTo(window.scrollX, window.scrollY);
        } else {
          // otherwise, scroll by our height offset
          window.scrollBy(0, offset);
        }

        cache.scrollY = window.scrollY;
        cache.posts[postId].height = boxSize;
      });
    });

    /**
     * Loop through all posts on the page, store their
     * initial height and order in the cache, and attach
     * the resize observer.
     */
    postsPage.querySelectorAll(".post").forEach((post, i) => {
      const postId = getPostId(post);
      // We only need posts before our anchor
      if (cache.anchorPostOrder && i >= cache.anchorPostOrder) {
        return;
      }
      cache.posts[postId] = {
        height: post.getBoundingClientRect().height,
        order: i
      };
      if (postId === cache.anchorPostId) {
        cache.anchorPostOrder = i;
      }
      resizeObserver.observe(post);
    });
  }

  $(Sugar).bind("postsloaded", function (event: Event, posts: HTMLElement[]) {
    // Initialize twitter embeds when new posts load or previewed
    if (posts.length && window.twttr) {
      const twitter = window.twttr as Twitter;
      twitter.widgets.load(posts[0].parentNode);
    }

    handleMastodonEmbeds();
  });

  handleMastodonEmbeds();
});
