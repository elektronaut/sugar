$.extend window.Sugar,

  Configuration: {}
  Initializers: {}

  stopwords: [
    'i', 'a', 'about', 'an', 'and', 'are', 'as', 'at', 'by', 'for', 'from', 'has', 'have',
    'how', 'in', 'is', 'it', 'la', 'my', 'of', 'on', 'or', 'that', 'the',
    'this', 'to', 'was', 'what', 'when', 'where', 'who', 'will', 'with', 'the'
  ]

  log: ->
    if this.Configuration.debug && console?
      if arguments.length == 1
        console.log arguments[0]
      else
        console.log arguments

  authToken: (elem) ->
    if elem
      $(elem).find("input[name='authenticity_token']").val()
    else
      $("input[name='authenticity_token']").val()

  init: ->
    for own name, initializer of this.Initializers
      initializer()
    $(this).trigger('ready')