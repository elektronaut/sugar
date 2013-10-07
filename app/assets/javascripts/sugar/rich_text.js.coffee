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

    quote: (text, html, username, permalink) ->
      wrapInBlockquote = (str) ->
        ("> " + line for line in str.split("\n")).join("\n")
      cite = if permalink
        "Posted by [#{username}](#{permalink}):"
      else
        "Posted by #{username}:"
      quotedPost = wrapInBlockquote("<cite>#{cite}</cite>\n\n#{toMarkdown html}")
      ["", quotedPost + "\n\n", ""]

  htmlDecorator =
    bold: (str)           -> ["<b>", str, "</b>"]
    emphasis: (str)       -> ["<i>", str, "</i>"]
    link: (url, name)     -> ["<a href=\"#{url}\">", name, "</a>"]
    image: (url)          -> ["<img src=\"", url, "\">"]
    mp3: (url, name)      -> ["<a href=\"#{url}\" class=\"mp3player\">", name, "</a>"]
    blockquote: (str)     -> ["<blockquote>", str, "</blockquote>"]
    code: (str, language) -> ["<pre><code class=\"#{language}\">", str, "</code></pre>"]
    spoiler: (str)        -> ["<div class=\"spoiler\">", str, "</div>"]

    quote: (text, html, username, permalink) ->
      cite = if permalink
        "Posted by <a href=\"#{permalink}\">#{username}</a>:"
      else
        "Posted by #{username}:"
      quotedPost = "<blockquote><cite>#{cite}</cite>\n\n#{text}</blockquote>"
      ["", quotedPost + "\n\n", ""]

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
    false

  formatButton = $("<li class=\"formatting\"><a>Markdown</a></li>")
  toolbar = $("<ul class=\"richTextToolbar\"></ul>").append(formatButton).insertBefore(textarea)

  setFormat(format)

  formatButton.find("a").click nextFormat

  getSelection = ->
    $(textarea).getSelection().text

  replaceSelection = (prefix, replacement, postfix) ->
    selection = getSelection()

    if typeof textarea.selectionStart != "undefined"
      selectionStart = textarea.selectionStart
      selectionEnd = textarea.selectionEnd

    $(textarea).replaceSelection(prefix + replacement + postfix)
    $(textarea).focus()

    # Modify selection
    if typeof textarea.setSelectionRange != "undefined"
      newSelectionStart = (selectionStart + prefix.length)
      newSelectionEnd  = (selectionEnd + (replacement.length - selection.length) + prefix.length)

      if selectionStart == selectionEnd
        # No text was selected, move the cursor
        textarea.setSelectionRange(newSelectionEnd, newSelectionEnd)
      else
        # Set the new selection range
        textarea.setSelectionRange(newSelectionStart, newSelectionEnd)

  addButton = (name, className, callback) ->
    link = $("<a title=\"#{name}\" class=\"#{className}\"><i class=\"icon-#{className}\"></i></a>")

    link.click ->
      [prefix, replacement, postfix] = callback(getSelection())
      replaceSelection(prefix, replacement, postfix)

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

  # Quoting
  $(Sugar).on "quote", (event, data) ->
    [prefix, replacement, postfix] = decorator.quote(
      data.text,
      data.html,
      data.username,
      data.permalink
    )
    replaceSelection(prefix, replacement, postfix)

  textarea.richtext = true


$(Sugar).bind 'ready modified', ->
  $('textarea.rich').each -> new Sugar.RichTextArea(this)

