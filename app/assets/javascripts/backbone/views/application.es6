Sugar.Views.Application = Backbone.View.extend({
  el: $('body'),

  initialize: function () {
    let postsSelector = 'body.discussion div.posts, ' +
                        'body.search div.posts, ' +
                        'body.user_profile div.posts';
    $(postsSelector).each(function() {
      this.view = new Sugar.Views.Posts({
        el: this
      });
    });
    $(Sugar).trigger('ready');
  }
});
