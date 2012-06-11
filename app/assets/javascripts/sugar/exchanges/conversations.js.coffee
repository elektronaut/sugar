$(Sugar).bind 'ready', ->

  $('#invite_participant_form').each ->
    $inputField = $(this).find('.username')

    usernames = []

    # Set up autocompletion
    $inputField.autocomplete [],
      autoFill: true
      width:    200
      data:     usernames

    # Load usernames from the backend on focus
    $inputField.focus ->
      if usernames.length == 0
        $.getJSON '/users.json', (results) ->
          usernames = (result.user.username for result in results)
          $inputField.setOptions
            data: usernames

    # Submit via AJAX and update the list
    $(this).submit ->
      $('#sidebar .participants ul').fadeTo('fast', 0.8)

      $.post this.action,
        username:           $inputField.val()
        authenticity_token: Sugar.authToken(this)
        (response) ->
          $('#sidebar .participants').html(response)
          $('#sidebar .participants ul').fadeTo(0, 0.8).fadeTo('fast', 1.0)

      $inputField.val('')
      return false
