Sugar.RichTextArea = (textArea, options) ->
  @textArea = textArea
  settings = jQuery.extend(
    className: "richTextToolbar"
  , options)

  @toolbar =
    settings: settings
    textArea: textArea
    listElement: false
    buttons: []
    addButton: (name, className, callback, options) ->
      li = document.createElement("li")
      a = document.createElement("a")
      i = document.createElement("i")
      a.title = name
      a.textArea = @textArea

      jQuery(a).click ->
        selection = textArea.selectedText()

        if typeof textArea.selectionStart != "undefined"
          selectionStart = textArea.selectionStart
          selectionEnd = textArea.selectionEnd

        [prefix, replacement, postfix] = callback(selection)
        textArea.replaceSelection(prefix + replacement + postfix)
        $(textArea).focus()

        if typeof textArea.setSelectionRange != "undefined"
          textArea.setSelectionRange(
            (selectionStart + prefix.length),
            (selectionEnd + (replacement.length - selection.length) + prefix.length)
          )

      jQuery(a).addClass className
      jQuery(i).addClass "icon-#{className}"
      jQuery(a).append(i)
      jQuery(li).append(a).appendTo @listElement
      @buttons.push li
      this

    create: ->
      unless @listElement
        @listElement = document.createElement("ul")
        jQuery(@listElement).addClass @settings.className
        jQuery(@listElement).insertBefore @textArea

  @textArea.selectedText = ->
    jQuery(this).getSelection().text

  @textArea.replaceSelection = (replacement) ->
    jQuery(this).replaceSelection replacement

  @textArea.wrapSelection = ->
    prepend = arguments[0]
    append = (if (arguments.length > 1) then arguments[1] else prepend)
    @replaceSelection prepend + @selectedText() + append

  @textArea.toolbar = @toolbar
  @toolbar.create()
  this

markdownDecorator =
  bold: (str)           -> ["**", str, "**"]
  emphasis: (str)       -> ["_", str, "_"]
  link: (url, name)     -> ["[", name, "](#{url})"]
  image: (url)          -> ["![](", url, ")"]
  mp3: (url, name)      -> ["<a href=\"#{url}\" class=\"mp3player\">", name, "</a>"]
  blockquote: (str)     -> ["", ("> " + line for line in str.split("\n")).join("\n"), ""]
  code: (str, language) -> ["```#{language}\n", str, "\n```"]
  spoiler: (str)        -> ["<div class=\"spoiler\">", str, "</div>"]

htmlDecorator =
  bold: (str)           -> ["<b>", str, "</b>"]
  emphasis: (str)       -> ["<i>", str, "</i>"]
  link: (url, name)     -> ["<a href=\"#{url}\">", name, "</a>"]
  image: (url)          -> ["<img src=\"", url, "\">"]
  mp3: (url, name)      -> ["<a href=\"#{url}\" class=\"mp3player\">", name, "</a>"]
  blockquote: (str)     -> ["<blockquote>", str, "</blockquote>"]
  code: (str, language) -> ["<pre><code class=\"#{language}\">", str, "</code></pre>"]
  spoiler: (str)        -> ["<div class=\"spoiler\">", str, "</div>"]

$(Sugar).bind 'ready modified', ->

  $('textarea.rich').each ->

    unless this.toolbar
      ta = new Sugar.RichTextArea(this)
      decorator = markdownDecorator

      # Setup the buttons
      ta.toolbar

        # Bold
        .addButton "Bold", "bold", (selection) ->
          decorator.bold(selection)

        # Italic
        .addButton "Italics", "italic", (selection) ->
          decorator.emphasis(selection)

        # Link
        .addButton "Link", "link", (selection) ->
          url = prompt("Enter link URL", "")
          name = if selection.length > 0 then selection else "Link text"
          url = if url.length > 0 then url else "http://example.com/"
          url = url.replace(/^(?!(f|ht)tps?:\/\/)/, 'http://')
          decorator.link(url, name)

        # Image tag
        .addButton "Image", "picture", (selection) ->
          url = if selection.length > 0 then selection else prompt("Enter image URL", "")
          decorator.image(url)

        # MP3 Player
        .addButton "MP3", "music", (selection) ->
          url = prompt("Enter MP3 URL", "")
          name = if selection.length > 0 then selection else prompt("Enter track title", "")
          url = if url.length > 0 then url else "http://example.com/example.mp3"
          url = url.replace(/^(?!(f|ht)tps?:\/\/)/, 'http://')
          decorator.mp3(url, name)

        # Block Quote
        .addButton "Block Quote", "quote-left", (selection) ->
          decorator.blockquote(selection)

        # Escape HTML
        .addButton "Code", "code", (selection) ->
          lang = prompt("Enter language (leave blank for no syntax highlighting)", "")
          decorator.code(selection, lang)

        # Spoiler
        .addButton "Spoiler", "warning-sign", (selection) ->
          decorator.spoiler(selection)
