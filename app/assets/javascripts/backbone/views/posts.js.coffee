class Sugar.Views.Posts extends Backbone.View
  el: $('div.posts')

  initialize: ->
    view = this
    view.post_views = []
    this.$('.post').each ->
      view.post_views.push new Sugar.Views.Post({el: this}).render()
    $(Sugar).bind 'postsloaded', (event, posts) ->
    	posts.each ->
	      view.post_views.push new Sugar.Views.Post({el: this}).render()
