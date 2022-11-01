import $ from "jquery";
import Sugar from "../../sugar";

/**
 * Handlers for scripted embed (social) quirks
 */
$(Sugar).bind("ready", function(){
  // Twitter doesn't have unbind, so we'll store our escape hatch
  var disableTwitterAnchorScroll = false;

  // Initialize twitter embeds when new posts load or previewed
  $(Sugar).bind("postsloaded", function(event, posts) {
    if (posts.length && window.twttr && window.twttr.widgets) {
      // We don't want to scroll to an anchor at this point
      disableTwitterAnchorScroll = true;
      window.twttr.widgets.load(posts[0].parentNode);
    }
  });

  // Handle updating scroll position to anchor for twitter embed loads
  function updateAnchorScroll() {
    if (disableTwitterAnchorScroll) {
      return;
    }
    var postId = window.location.hash.match(/(post\-\d+)/);
    if (postId.length) {
      var rPost = document.querySelector('a[name="' + postId[1] + '"].anchor');
      if (rPost) {
        rPost.scrollIntoView();
      }
    }
  }
  if (window.twttr) {
    twttr.ready(function (twttr) {
      twttr.events.bind('rendered', updateAnchorScroll);
    });
  }
});
