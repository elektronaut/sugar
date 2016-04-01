Sugar.Models.Post = Backbone.Model.extend({
  paramRoot: 'post',
  idAttribute: 'id',

  defaults: {
    body: '',
    user_id: false,
    exchange_id: false,
    exchange_type: 'Exchange'
  },

  editableBy: function (user) {
    if (user && (user.id === this.get('user_id') || user.isModerator())) {
      return true;
    } else {
      return false;
    }
  },

  urlRoot: function () {
    if (this.get('exchange_id') && this.get('exchange_type')) {
      return "/" + this.get('exchange_type').toLowerCase() +
             's/' + this.get('exchange_id') + '/posts';
    } else {
      return '/posts';
    }
  },

  editUrl: function (options) {
    if (options && options.timestamp) {
      return this.url() + '/edit?' + new Date().getTime();
    } else {
      return this.url() + '/edit';
    }
  }
});

Sugar.Collections.Posts = Backbone.Collection.extend({
  model: Sugar.Models.Post,
  url: '/posts'
});
