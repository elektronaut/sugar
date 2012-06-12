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

  # Prepare post for submissin
  prepare_submission = (form) ->
    body = $("#compose-body").val()

    # Abort if the post is empty
    return false  if body.replace(/\s+/, "") is ""

    if $.browser.msie
      # Don't do anything fancy in IE, just submit the post
      # without AJAX.
      $(Sugar).trigger "posting-status", [ "Posting&hellip;" ]

    else
      $(Sugar).trigger "posting-status", [ "Validating post&hellip;" ]

      # Auto-link URLs
      body = body.replace(/(^|\s)((ftp|https?):\/\/[^\s]+\b\/?)/g, "$1<a href=\"$2\">$2</a>")

      # Inject the post in a hidden <div>
      if $("#hiddenPostVerifier").length < 1
        $(document.body).append "<div id=\"hiddenPostVerifier\"></div>"
      post_verifier = $("#hiddenPostVerifier")
      post_verifier.show()
      post_verifier.html body
      post_verifier.hide()

      # Make links to the same domain relative
      current_domain = document.location.toString().match(/^(https?:\/\/[\w\d\-\.:]+)/)[1]
      post_links = post_verifier.find("a")
      if post_links.length > 0
        a = 0
        while a < post_links.length
          post_links[a].href = post_links[a].href.replace(current_domain, "")
          a += 1
        $("#compose-body").val post_verifier.html()

      # Preload images, detect height and width
      post_images = post_verifier.find("img")
      loaded_images = []
      if post_images.length > 0

        # Async loading event
        post_images.each ->
          $(this).load ->
            loaded_images.push this

        # Check loading of images
        post_verifier.cycles = 0
        post_verifier.load_interval = setInterval(->
          post_verifier.cycles += 1
          $(Sugar).trigger "posting-status", [ "Loading image " + loaded_images.length + " of " + post_images.length + "&hellip;" ]

          # Handle failure
          if post_verifier.cycles >= 80
            clearInterval post_verifier.load_interval
            if confirm("One or more of your images timed out. Post anyway?")
              $(loaded_images).each ->
                $(this).attr "height", @height
                $(this).attr "width", @width

              $("#compose-body").val post_verifier.html()
              submit_post form
            else
              $(Sugar).trigger "posting-complete"

          # All images loaded
          if loaded_images.length is post_images.length
            post_images.each ->
              $(this).attr "height", @height
              $(this).attr "width", @width

            $("#compose-body").val post_verifier.html()
            clearInterval post_verifier.load_interval
            submit_post form
        , 100)
        false
      else
        submit_post form
        false

  # Form event handler
  $("#replyText form").submit ->
    prepare_submission this
