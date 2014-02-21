class Sugar.Views.Post extends Backbone.View
  el: $('div.post')

  editing: false

  events:
    'click a.quote_post': 'quote'
    'click a.edit_post': 'edit'

  initialize: ->
    if $(this.el.id)
      this.model = this.modelFromExistingElement()
    else
      this.model = new Sugar.Models.Post()

  modelFromExistingElement: ->
    if this.el.id.match(/([\d]+)$/)
      id = this.el.id.match(/([\d]+)$/)[1]
    else
      id = null

    new Sugar.Models.Post({
      id:            id,
      user_id:       $(this.el).data('user_id'),
      exchange_id:   $(this.el).data('exchange_id'),
      exchange_type: $(this.el).data('exchange_type'),
      body:          this.stripWhitespace(this.$('.body .content').text())
    })

  stripWhitespace: (string) ->
    string
      .replace(/^[\s]*/, '') # Strip leading space
      .replace(/[\s]*$/, '') # Strip trailing space

  render: ->
    view = this
    this.$('.post_functions').each ->
      links = []
      if currentUser = Sugar.getCurrentUser()
        if view.model.editableBy(currentUser)
          links.push '<a href="#" class="edit_post">Edit</a>'
        links.push '<a href="#" class="quote_post">Quote</a>'
      $(this).html(links.join(' | '))

    this.applyAmazonReferralCode()
    this.applySpoiler()
    this.wrapInstagramEmbeds()
    this

  edit: (event) ->
    event.preventDefault()
    unless @editing
      this.$('.body').hide()
      $(this.el).append("<div class=\"edit\"><span class=\"ticker\">Loading...</span></div>")
      this.$('.edit').load this.model.editUrl(timestamp: true), ->
        $(Sugar).trigger('modified')
      @editing = true

  # Quote the post
  quote: (event) ->
    event.preventDefault()

    if window.getSelection? and window.getSelection().containsNode(this.el, true)
      text = window.getSelection().toString()
      html = text

    if !text? || text.trim() == ""
      text = @stripWhitespace(this.$('.body .content').text())
      html = @stripWhitespace(this.$('.body .content').html())

    if $(this.el).hasClass('me_post')
      username  = $(this.el).find('.body .poster').text()
      permalink = null
    else
      username  = $(this.el).find('.post_info .username a').text()
      permalink = $(this.el).find('.post_info .permalink a').get()[0].href.replace(/^https?:\/\/([\w\d\.:\-]*)/, '')

    # Hide spoilers
    text = text.replace(/class="spoiler revealed"/g, 'class="spoiler"')
    html = html.replace(/class="spoiler revealed"/g, 'class="spoiler"')

    $(Sugar).trigger "quote",
      username: username
      permalink: permalink
      text: text
      html: html

  # Apply functionality to spoiler tags
  applySpoiler: ->
    $(this.el).find('.spoiler').click ->
      $(this).toggleClass 'revealed'

  # Apply referral code to Amazon links
  applyAmazonReferralCode: ->
    if referral_id = Sugar.Configuration.amazonAssociatesId
      $(this.el).find('.body a').each ->
        link = this
        if !$.data(link, 'amazon_associates_referral_id') && link.href.match /https?:\/\/([\w\d\-\.])*(amazon|junglee)(\.com?)*\.([\w]{2,3})\//
          $.data(link, 'amazon_associates_referral_id', referral_id)
          return if link.href.match /(\?|&)tag=/

          link.href += if link.href.match(/\?/) then '&' else '?'
          link.href += 'tag=' + referral_id

  wrapInstagramEmbeds: ->
    $(this.el).find("iframe[src*='//instagram.com/']").each ->
      unless $(this).parent().hasClass("instagram-wrapper")
        $(this).wrap('<div class="instagram-wrapper">')

