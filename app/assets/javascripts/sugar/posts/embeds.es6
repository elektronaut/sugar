/**
 * Handlers for scripted embed (social) quirks
 */
$(Sugar).bind('ready', function(){
  
  // Re-establish anchor position on initial page's twitter widgets load
  if ($('.twitter-tweet,twitterwidget').length && window.twttr && window.twttr.events) {
    var anchor = $('a[name="' + window.location.hash.substr(1) + '"]');
    if (anchor.length) {
      function scrollPage() {
        window.scrollTo(0, anchor.offset().top);
      }
      window.twttr.events.bind('rendered', scrollPage);
      window.twttr.events.bind('loaded', function tweetsLoaded() {
        scrollPage();
        window.twttr.events.unbind('rendered', scrollPage);
        window.twttr.events.unbind('loaded', tweetsLoaded);
      });
    }
  }

  // Initialize twitter embeds when new posts load or previewed
  $(Sugar).bind('postsloaded', function(event, posts) {
    if (posts.length && window.twttr && window.twttr.widgets) {
      window.twttr.widgets.load(posts[0].parentNode);
    }
  });

});