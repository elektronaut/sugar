class Sugar.Models.Post extends Backbone.Model
  paramRoot: 'post'

  idAttribute: "id"

  defaults:
    body: ''
    'user_id': false
    'exchange_id': false
    'exchange_type': "Exchange"

  editableBy: (user) ->
    if user and (user.id == this.get('user_id') or user.isModerator())
      true
    else
      false

  urlRoot: ->
    if this.get('exchange_id') && this.get('exchange_type')
      "/" + this.get('exchange_type').toLowerCase() + 's/' + this.get('exchange_id') + '/posts'
    else
      '/posts'

  editUrl: (options) ->
    options ||= {}
    if options.timestamp
      this.url() + '/edit?' + new Date().getTime()
    else
      this.url() + '/edit'

class Sugar.Collections.Posts extends Backbone.Collection
  model: Sugar.Models.Post
  url: '/posts'
