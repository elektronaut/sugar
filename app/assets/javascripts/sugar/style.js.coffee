# Various cosmetic enhancements

$(Sugar).bind 'ready modified', ->

  # Wrap button content in a span
  $('a.button, button').each ->
    if $(this).find('span').length == 0
        $(this).wrapInner('<span />')

$(Sugar).bind 'ready', ->

  # Make entire category <li> clickable
  $('ul.categories li a').each ->
    url = this.href;
    $(this).closest('li').click ->
      document.location = url;

  # Adjust min-width of #content to always contain table.discussions
  $('table.discussions').each ->
    $('#content').css 'min-width', ($(this).outerWidth() + 'px')

  # Adjust min-width of #wrapper to always contain content and sidebar if the sidebar exists
  $('#sidebar').each ->
    minWidth = $('#content').outerWidth() + $('#sidebar').outerWidth()
    $('#wrapper').css 'min-width', (minWidth + 'px')

  # Tabs on posting form
  $('#reply-tabs').each ->
    window.replyTabs = new Sugar.Tabs this, showFirstTab: false
    if $('body.last_page').length > 0
      window.replyTabs.controls.showTab window.replyTabs.tabs[0]

    # Automatically show the first tab when the input is focused
    $('#replyText textarea').on "focus", ->
      window.replyTabs.controls.showTab window.replyTabs.tabs[0]

    # Show write tab when quoting is triggered
    $(Sugar).on "quote", (event, data) ->
      window.replyTabs.controls.showTab window.replyTabs.tabs[0]

  # Tabs on signup
  $('#signup-tabs').each ->
    new Sugar.Tabs this, showFirstTab: true

  # Tabs on admin configuration
  $('.admin.configuration .tabs').each ->
    new Sugar.Tabs this, showFirstTab: true
