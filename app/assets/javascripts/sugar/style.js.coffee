# Wrap buttons in span
$(Sugar).bind 'ready modified', ->
  $('a.button, button').each ->
    if $(this).find('span').length == 0
        $(this).wrapInner('<span />')
