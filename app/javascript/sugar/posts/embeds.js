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
});
