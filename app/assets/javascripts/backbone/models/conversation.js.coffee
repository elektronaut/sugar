class Sugar.Models.Conversation extends Sugar.Models.Exchange
  paramRoot: 'conversation'

  urlRoot: ->
    '/conversations'

class Sugar.Collections.Conversations extends Backbone.Collection
  model: Sugar.Models.Conversation
  url: '/conversations'
