$(Sugar).bind 'ready', ->

  $("#search form").each ->
    form = this

    # Observe the search mode selection box, set the proper action.
    $(form).find("#search_mode").change ->
      @parentNode.action = @value

    # Make better search URLs
    $(form).submit ->
      action = form.action
      unless action.match(/^https?:\/\//)
        # Safari doesn't like document.location being set to a relative path
        baseDomain = document.location.toString().match(/^(https?:\/\/[\w\d\-\.]+)/)[1]
        action = baseDomain + action
      query = encodeURIComponent($(form).find(".query").val())
      searchURL = action + "?q=" + query
      document.location = searchURL
      false