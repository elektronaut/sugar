Sugar.RichTextArea = (textarea, options) ->

  return this if textarea.richtext

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

  settings = jQuery.extend(
    className: "richTextToolbar"
  , options)

  decorator = markdownDecorator

  if $(textarea).data('formats')
    formats = $(textarea).data('formats').split(" ")
  else
    formats = ["markdown"]

  if $(textarea).data("format-binding")
    format = $(textarea).closest("form").find($(textarea).data("format-binding")).val()

  format ||= formats[0]

  setFormat = (newFormat) ->
    format = newFormat
    if format == "markdown"
      label = "Markdown"
      decorator = markdownDecorator
    else if format == "html"
      label = "HTML"
      decorator = htmlDecorator

    formatButton.find("a").html(label)
    if $(textarea).data("format-binding")
      $(textarea).closest("form").find($(textarea).data("format-binding")).val(format)

  nextFormat = ->
    setFormat formats[(formats.indexOf(format) + 1) % formats.length]

  formatButton = $("<li class=\"formatting\"><a>Markdown</a></li>")
  toolbar = $("<ul class=\"richTextToolbar\"></ul>").append(formatButton).insertBefore(textarea)

  setFormat(format)

  formatButton.find("a").click ->
    nextFormat()
    false

  addButton = (name, className, callback) ->
    link = $("<a title=\"#{name}\" class=\"#{className}\"><i class=\"icon-#{className}\"></i></a>")

    link.click ->
      selection = $(textarea).getSelection().text

      if typeof textarea.selectionStart != "undefined"
        selectionStart = textarea.selectionStart
        selectionEnd = textarea.selectionEnd

      [prefix, replacement, postfix] = callback(selection)
      $(textarea).replaceSelection(prefix + replacement + postfix)
      $(textarea).focus()

      if typeof textarea.setSelectionRange != "undefined"
        textarea.setSelectionRange(
          (selectionStart + prefix.length),
          (selectionEnd + (replacement.length - selection.length) + prefix.length)
        )

    $("<li class=\"button\"></li>").append(link).insertBefore(formatButton)

  # Bold button
  addButton "Bold", "bold", (selection) -> decorator.bold(selection)

  # Italic button
  addButton "Italics", "italic", (selection) -> decorator.emphasis(selection)

  # Link button
  addButton "Link", "link", (selection) ->
    url = prompt("Enter link URL", "")
    name = if selection.length > 0 then selection else "Link text"
    url = if url.length > 0 then url else "http://example.com/"
    url = url.replace(/^(?!(f|ht)tps?:\/\/)/, 'http://')
    decorator.link(url, name)

  # Image tag
  addButton "Image", "picture", (selection) ->
    url = if selection.length > 0 then selection else prompt("Enter image URL", "")
    decorator.image(url)

  # MP3 button
  addButton "MP3", "music", (selection) ->
    url = prompt("Enter MP3 URL", "")
    name = if selection.length > 0 then selection else prompt("Enter track title", "")
    url = if url.length > 0 then url else "http://example.com/example.mp3"
    url = url.replace(/^(?!(f|ht)tps?:\/\/)/, 'http://')
    decorator.mp3(url, name)

  # Block Quote
  addButton "Block Quote", "quote-left", (selection) -> decorator.blockquote(selection)

  # Code button
  addButton "Code", "code", (selection) ->
    lang = prompt("Enter language (leave blank for no syntax highlighting)", "")
    decorator.code(selection, lang)

  # Spoiler button
  addButton "Spoiler", "warning-sign", (selection) -> decorator.spoiler(selection)

  textarea.richtext = true


$(Sugar).bind 'ready modified', ->
  $('textarea.rich').each -> new Sugar.RichTextArea(this)

