class Sugar.Views.Application extends Backbone.View
  el: $('body')

  initialize: ->
    $('div.posts').each ->
      this.view = new Sugar.Views.Posts({el: this})

    $(Sugar).trigger('ready')

