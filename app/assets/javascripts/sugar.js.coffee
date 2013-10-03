$.extend window.Sugar,

  Configuration: {}

  stopwords: [
    'i', 'a', 'about', 'an', 'and', 'are', 'as', 'at', 'by', 'for', 'from', 'has', 'have',
    'how', 'in', 'is', 'it', 'la', 'my', 'of', 'on', 'or', 'that', 'the',
    'this', 'to', 'was', 'what', 'when', 'where', 'who', 'will', 'with', 'the'
  ]

  init: ->
    this.Application = new Sugar.Views.Application()

  extend: (extension) ->
    $.extend(Sugar, extension)

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

  # Focus the reply textarea, optionally adding content
  compose: (options) ->
    options = $.extend({}, options)

    # Show the first tab
    if window.replyTabs
      window.replyTabs.controls.showTab window.replyTabs.tabs[0]

    $("#replyText textarea").each ->
      if options.add
        content = $(this).val()
        newContent = options.add + "\n\n"

        # Try to insert the content at the cursor
        if typeof this.selectionStart != "undefined"
          before = content[0...this.selectionStart]
          after = content[this.selectionStart..]
          lineBreak = if before.length > 0 then "\n\n" else ""
          $(this).val(before + lineBreak + newContent + after)

          # Move the cursor
          if this.setSelectionRange
            newPosition = this.selectionStart + (lineBreak + newContent).length
            this.setSelectionRange newPosition, newPosition

        # No support for selectionStart, just add it at the end
        else
          $(this).val(content + newContent)

      this.scrollTop = this.scrollHeight
      $(this).focus()
