import $ from "jquery";
import Sugar from "../../sugar";

/**
 * Handlers for scripted embed (social) quirks
 */
$(Sugar).bind("ready", function(){

  // Initialize twitter embeds when new posts load or previewed
  $(Sugar).bind("postsloaded", function(event, posts) {
    if (posts.length && window.twttr && window.twttr.widgets) {
      window.twttr.widgets.load(posts[0].parentNode);
    }
  });

  var scrollHeightCache = document.documentElement.scrollHeight;
  var scrollYCache = window.scrollY;
  const resizeObserver = new ResizeObserver(function (entries) {
    entries.forEach(function () {
      if (scrollYCache !== window.scrollY) {
        // Chrome updates the scroll position, but not the scroll!
        window.scrollTo(window.scrollX, window.scrollY);
      } else if (document.documentElement.scrollHeight !== scrollHeightCache) {
        var scrollYBy = document.documentElement.scrollHeight - scrollHeightCache;
        window.scrollBy(0, scrollYBy);
      }
      scrollYCache = window.scrollY;
      scrollHeightCache = document.documentElement.scrollHeight;
    });
  });

  resizeObserver.observe(document.querySelector(".posts"));
});
