$(Sugar).bind 'ready', ->

	# Checkbox logic
  $('.edit_user_profile').each ->

    checkTrusted = ->
      if $('#user_user_admin:checked').val() || $('#user_moderator:checked').val()
        $('#user_trusted').attr('checked', true)
        $('#user_trusted').attr('disabled', true)
      else
        $('#user_trusted').attr('disabled', false)

    checkAdmin = ->
      if $('#user_admin:checked').val()
        $('#user_moderator').attr('checked', true).attr('disabled', true)
        $('#user_user_admin').attr('checked', true).attr('disabled', true)
      else
        $('#user_moderator').attr('disabled', false)
        $('#user_user_admin').attr('disabled', false)

    $('#user_moderator, #user_user_admin').click(checkTrusted)
    $('#user_admin').click(checkAdmin).click(checkTrusted)

    checkAdmin();
    checkTrusted();
