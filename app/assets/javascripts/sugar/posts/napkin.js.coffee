# Make drawings clickable
$(Sugar).bind 'ready postsloaded', ->
  $('.drawing img').each ->
    if !$(this).data('napkin_applied')
      $(this).click ->
        swfobject.getObjectById("napkin").setBackground @src  if swfobject.getObjectById("napkin")
      $(this).data('napkin_applied', true)

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
      swfobject.getObjectById("napkin").uploadDrawing()

    # Callback from napkin
    window.onDrawingUploaded = (url) ->
      clear_status()
      window.replyTabs.controls.showTab(window.replyTabs.tabs[0]);
      Sugar.loadNewPosts()
