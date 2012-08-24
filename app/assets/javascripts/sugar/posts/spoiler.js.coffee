$(Sugar).bind 'postsloaded', ->

  $('.spoiler').each ->
    if $(this).find('.innerSpoiler').length == 0
      $(this)
        .wrapInner('<span class="innerSpoiler"></span>')
        .prepend('<span class="spoilerLabel">Spoiler!</span> ')

      $(this).find('.innerSpoiler').css('visibility', 'hidden')
      $(this).hover ->
        $(this).find('.innerSpoiler').css('visibility', 'visible')
      , ->
        $(this).find('.innerSpoiler').css('visibility', 'hidden')
