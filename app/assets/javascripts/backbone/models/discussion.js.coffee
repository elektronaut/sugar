class Sugar.Models.Discussion extends Sugar.Models.Exchange
  paramRoot: 'discussion'

  urlRoot: ->
    '/discussions'

class Sugar.Collections.Discussions extends Backbone.Collection
  model: Sugar.Models.Discussion
  url: '/discussions'
