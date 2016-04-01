Sugar.Models.Discussion = Sugar.Models.Exchange.extend({
  paramRoot: 'discussion',

  urlRoot: function () {
    return '/discussions';
  }
});

Sugar.Collections.Discussions = Backbone.Collection.extend({
  model: Sugar.Models.Discussion,
  url: '/discussions'
});
