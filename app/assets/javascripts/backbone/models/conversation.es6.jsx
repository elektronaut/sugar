Sugar.Models.Conversation = Sugar.Models.Exchange.extend({
  paramRoot: 'conversation',

  urlRoot: function () {
    return '/conversations';
  }
});

Sugar.Collections.Conversations = Backbone.Collection.extend({
  model: Sugar.Models.Conversation,
  url: '/conversations'
});
