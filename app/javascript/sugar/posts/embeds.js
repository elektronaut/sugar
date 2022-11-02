import $ from "jquery";
import Sugar from "../../sugar";

/**
 * Handlers for scripted embed (social) quirks
 */
$(Sugar).bind("ready", function(){

  // Fix for misbehaving or missing scroll anchoring
  const postsPage = document.querySelector(".posts");
  if (postsPage) {
    const cache = {
      posts: {},
      anchorPost: 0,
      anchorPostOrder: 0,
      scrollY: window.scrollY
    };
    let anchorPost = window.location.hash.match(/post-(\d+)/);
    if (anchorPost && anchorPost.length) {
      cache.anchorPost = anchorPost[1];
    }

    const resizeObserver = new ResizeObserver(function (posts) {
      posts.forEach(post => {
        const postId = post.target.dataset.post_id;
        const pCache = cache.posts[postId];
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
        } else if (pCache.order < cache.anchorPostOrder) {
          window.scrollBy(0, offset);
        }

        cache.scrollY = window.scrollY;
        cache.posts[postId].height = boxSize;
      });
    });

    postsPage.querySelectorAll(".post").forEach((post, i) => {
      const postId = post.dataset.post_id;
      cache.posts[postId] = {
        height: post.getBoundingClientRect().height,
        order: i
      };
      if (postId === cache.anchorPost) {
        cache.anchorPostOrder = i;
      }
      resizeObserver.observe(post);
    });
  }

  // Initialize twitter embeds when new posts load or previewed
  $(Sugar).bind("postsloaded", function (event, posts) {
    // Re-enable scroll anchoring
    if (posts.length && window.twttr && window.twttr.widgets) {
      window.twttr.widgets.load(posts[0].parentNode);
    }
  });

});
