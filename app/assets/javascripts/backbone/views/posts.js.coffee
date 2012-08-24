class Sugar.Views.Posts extends Backbone.View
  el: $('div.posts')

  initialize: ->
    view = this
    view.postViews = []

    # Render posts
    $(Sugar).bind 'postsloaded', (event, posts) ->
      posts.each ->
        view.postViews.push new Sugar.Views.Post({el: this}).render()

    $(Sugar).trigger 'postsloaded', [$('.post')]
