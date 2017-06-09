/**
 * Handlers for scripted embed (social) quirks
 */
$(Sugar).bind('ready', function(){
  
  // Re-establish anchor position on initial page's twitter widgets load
  if ($('.twitter-tweet,twitterwidget').length && twttr && twttr.events) {
    twttr.events.bind('loaded', function refocus() {
      var a = window.location.hash;
      window.location.hash = '#';
      window.location.hash = a;
      twttr.events.unbind('loaded', refocus);
    });
  }

  // Initialize twitter embeds when new posts load or previewed
  $(Sugar).bind('postsloaded', function(event, posts) {
    if (posts.length && twttr && twttr.widgets) {
      twttr.widgets.load(posts[0].parentNode);
    }
  });

});
