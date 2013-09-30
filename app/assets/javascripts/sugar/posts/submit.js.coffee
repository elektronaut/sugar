$(Sugar).bind 'ready', ->

  # Submit post via AJAX
  submit_post = (form) ->
    $(Sugar).trigger "posting-status", [ "Posting, please wait&hellip;" ]
    if $(form).hasClass("livePost")
      body = $("#compose-body").val()
      $.ajax
        url: form.action
        type: "POST"
        data:
          "post[body]": body
          authenticity_token: Sugar.authToken(this)

        success: ->
          $("#compose-body").val ""
          $(".posts #previewPost").remove()
          Sugar.loadNewPosts()

        error: (xhr, text_status, error_thrown) ->
          alert text_status
          if body is ""
            alert "Your post is empty!"
          else if text_status is "timeout"
            alert "Error: The request timed out."
          else
            alert "There was a problem validating your post."

        complete: ->
          $(Sugar).trigger "posting-complete"
    else
      form.submit()

  # Form event handler
  $("#replyText form").submit ->
    unless $(this).find("#compose-body").val().replace(/\s+/, "") is ""
      submit_post this
    false
