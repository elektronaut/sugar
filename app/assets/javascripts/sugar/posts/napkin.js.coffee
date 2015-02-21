napkinObject = ->
  swfobject.getObjectById("napkin")

withNapkinObject = (fn) ->
  (fn(napkinObject())) if napkinObject()

# Make drawings clickable
$(Sugar).bind 'ready postsloaded', ->
  $('.drawing img').each ->
    if !$(this).data('napkin_applied')
      img = this
      $(this).data('napkin_applied', true)
      $(this).click -> withNapkinObject (obj) -> obj.setBackground(img.src)

# Drawing upload handler
$(Sugar).bind 'ready', ->
  if $("#napkin").length > 0

    $buttons = $('#napkin-submit')

    show_status = (message) ->
      $buttons.find('.status').html(message)
      $buttons.find('button').hide()
      $buttons.addClass('posting')

    clear_status = ->
      $buttons.find('.status').html('')
      $buttons.find('button').fadeIn('fast')
      $buttons.removeClass('posting')

    # Button handler
    $buttons.find('button').click ->
      show_status 'Posting, please wait&hellip;'
      withNapkinObject (obj) -> obj.uploadDrawing()

    # Callback from napkin
    window.onDrawingUploaded = (url) ->
      clear_status()
      window.replyTabs.controls.showTab(window.replyTabs.tabs[0]);
      Sugar.loadNewPosts()
