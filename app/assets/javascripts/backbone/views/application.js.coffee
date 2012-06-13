class Sugar.Views.Application extends Backbone.View
  el: $('body')

  initialize: ->
    $('body.discussion div.posts').each ->
      this.view = new Sugar.Views.Posts({el: this})

    $(Sugar).trigger('ready')
