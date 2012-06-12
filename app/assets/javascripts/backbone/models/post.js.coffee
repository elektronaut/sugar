class Sugar.Models.Post extends Backbone.Model
  paramRoot: 'post'

  idAttribute: "id"

  defaults:
    body: ''
    'user_id': false
    'discussion_id': false

  editableBy: (user) ->
    if user and (user.id == this.get('user_id') or user.isModerator())
      true
    else
      false

  urlRoot: ->
    if this.get('discussion_id')
      '/discussions/' + this.get('discussion_id') + '/posts'
    else
      '/posts'

  editUrl: ->
    this.url() + '/edit'

class Sugar.Collections.Posts extends Backbone.Collection
  model: Sugar.Models.Post
  url: '/posts'
