Sugar.Views.Posts = Backbone.View.extend({
  el: $('div.posts'),

  initialize: function () {
    $(Sugar).bind('postsloaded', function(event, posts) {
      posts.each(function() {
        new Sugar.Views.Post({ el: this }).render();
      });
    });
    $(Sugar).trigger('postsloaded', [$(this.el).find('.post')]);
  }
});
