class Sugar.Views.Post extends Backbone.View
  el: $('div.post')

  events:
    'click a.quote_post': 'quote'
    'click a.edit_post': 'edit'

  initialize: ->
    if $(this.el.id)
      this.model = this.modelFromExistingElement()
    else
      this.model = new Sugar.Models.Post()

  modelFromExistingElement: ->
    new Sugar.Models.Post({
      id: this.el.id.match(/([\d]+)$/)[1],
      'user_id': $(this.el).data('user_id'),
      'discussion_id': $(this.el).data('discussion_id'),
      body: this.fromHtml(this.$('.body .content').html())
    })

  fromHtml: (body) ->
    body
      .replace(/^[\s]*/, '')          # Strip leading space
      .replace(/[\s]*$/, '')          # Strip trailing space
      .replace(/<br[\s\/]*>/g, "\n"); # Change <br /> to line breaks

  render: ->
    view = this
    this.$('.post_functions').each ->
      links = []
      if currentUser = Sugar.getCurrentUser()
        if view.model.editableBy(currentUser)
          links.push '<a href="#" class="edit_post">Edit</a>'
        links.push '<a href="#" class="quote_post">Quote</a>'

      $(this).html(links.join(' | '))

    return this

  edit: (event) ->
    event.preventDefault();
    this.$('.body').html '<span class="ticker">Loading...</span>'
    this.$('.body').load this.model.editUrl(), ->
      Sugar.Initializers.richText();
      $(Sugar).trigger('modified')

  quote: (event) ->
    event.preventDefault();
    Sugar.quotePost(this.el)
