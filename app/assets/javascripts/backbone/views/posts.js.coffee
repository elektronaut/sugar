class Sugar.Views.Posts extends Backbone.View
  el: $('div.posts')

  initialize: ->
    posts = this
    this.postViews = []
    this.$('.post').each ->
      posts.postViews.push new Sugar.Views.Post({el: this}).render()

