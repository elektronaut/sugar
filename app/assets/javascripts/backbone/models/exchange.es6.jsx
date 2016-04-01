Sugar.Models.Exchange = Backbone.Model.extend({
  paramRoot: 'exchange',
  idAttribute: 'id',

  defaults: {
    title: '',
    poster_id: false,
    last_poster_id: false,
    posts_count: false
  },

  urlRoot: function () {
    return '/discussions';
  },

  editUrl: function() {
    return this.url() + '/edit';
  },

  postsCountUrl: function (options) {
    if (options && options.timestamp) {
      return this.url() + '/posts/count.json?' + new Date().getTime();
    } else {
      return this.url() + '/posts/count.json'
    }
  }
});
