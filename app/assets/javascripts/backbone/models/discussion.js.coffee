class Sugar.Models.Discussion extends Backbone.Model
  paramRoot: 'discussion'

  idAttribute: "id"

  defaults:
    title: ''
    category_id: false
    poster_id: false
    last_poster_id: false
    posts_count: false

  urlRoot: ->
    '/discussions'

  editUrl: ->
    this.url() + '/edit'

  postsCountUrl: ->
    this.url() + '/posts/count.json'

class Sugar.Collections.Discussions extends Backbone.Collection
  model: Sugar.Models.Discussion
  url: '/discussions'
