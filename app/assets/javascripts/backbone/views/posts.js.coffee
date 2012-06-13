class Sugar.Views.Posts extends Backbone.View
  el: $('div.posts')

  initialize: ->
    view = this
    view.postViews = []

    # Render existing posts
    this.$('.post').each ->
      view.postViews.push new Sugar.Views.Post({el: this}).render()

    # Render additional posts when loaded
    $(Sugar).bind 'postsloaded', (event, posts) ->
    	posts.each ->
	      view.postViews.push new Sugar.Views.Post({el: this}).render()
