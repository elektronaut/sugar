Sugar.Views.Posts = Backbone.View.extend({
  el: $('div.posts'),

  initialize: function () {
    // Re-establish anchor position after twitter widgets load
    $(function(){
      if ($('.twitter-tweet,twitterwidget').length && twttr && twttr.events) {
        twttr.events.bind('loaded', function refocus() {
          var a = window.location.hash;
          window.location.hash = '#';
          window.location.hash = a;
          twttr.events.unbind('loaded', refocus);
        });
      }
    });

    $(Sugar).bind('postsloaded', function(event, posts) {
      posts.each(function() {
        new Sugar.Views.Post({ el: this }).render();
      });
    });
    $(Sugar).trigger('postsloaded', [$(this.el).find('.post')]);
  }
});
