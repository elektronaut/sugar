class MarkdownDecorator
  blockquote: (str)     -> ["", ("> " + line for line in str.split("\n")).join("\n"), ""]
  bold: (str)           -> ["**", str, "**"]
  code: (str, language) -> ["```#{language}\n", str, "\n```"]
  emphasis: (str)       -> ["_", str, "_"]
  image: (url)          -> ["![](", url, ")"]
  youtube: (url)          -> ["!y[Video title](", url, ")"]
  link: (url, name)     -> ["[", name, "](#{url})"]
  quote: (text, html, username, permalink) ->
    wrapInBlockquote = (str) ->
      ("> " + line for line in str.split("\n")).join("\n")
    cite = if permalink
      "Posted by [#{username}](#{permalink}):"
    else
      "Posted by #{username}:"
    quotedPost = wrapInBlockquote("<cite>#{cite}</cite>\n\n#{html}")
    ["", quotedPost + "\n\n", ""]
  spoiler: (str)        -> ["<div class=\"spoiler\">", str, "</div>"]

class HtmlDecorator
  blockquote: (str)     -> ["<blockquote>", str, "</blockquote>"]
  bold: (str)           -> ["<b>", str, "</b>"]
  code: (str, language) -> ["```#{language}\n", str, "\n```"]
  emphasis: (str)       -> ["<i>", str, "</i>"]
  image: (url)          -> ["<img src=\"", url, "\">"]
  youtube: (url) ->
    code = undefined
    regExp = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/
    match = url.match(regExp)
    if match and match[7].length is 11
      code = match[7]
    else
      return [""]
    return ["<iframe src=\"https://www.youtube.com/embed/", code, "\" frameborder=\"0\" allowfullscreen></iframe>"]
  link: (url, name)     -> ["<a href=\"#{url}\">", name, "</a>"]
  quote: (text, html, username, permalink) ->
    cite = if permalink
      "Posted by <a href=\"#{permalink}\">#{username}</a>:"
    else
      "Posted by #{username}:"
    content = html.replace(/\n/g, "").replace(/<br[\s\/]*>/g, "\n")
    quotedPost = "<blockquote><cite>#{cite}</cite>#{content}</blockquote>"
    ["", quotedPost + "\n\n", ""]
  spoiler: (str)        -> ["<div class=\"spoiler\">", str, "</div>"]

# Gets the selected text from an element
getSelection = (elem) -> $(elem).getSelection().text

# Gets the selected range from an element
getSelectionRange = (elem) ->
  if typeof elem.selectionStart != "undefined"
    [elem.selectionStart, elem.selectionEnd]
  else
    [0, 0]

# Sets a new selection range for object
setSelectionRange = (elem, start, end) ->
  if typeof elem.setSelectionRange != "undefined"
    elem.setSelectionRange(start, end)

adjustSelection = (elem, callback) ->
  selectionLength = getSelection(elem).length
  [start, end] = getSelectionRange(elem)
  [replacementLength, prefixLength] = callback()
  newEnd = (end + (replacementLength - selectionLength) + prefixLength)
  newStart = if start == end then newEnd else (start + prefixLength)
  setSelectionRange(elem, newStart, newEnd)

replaceSelection = (elem, prefix, replacement, postfix) ->
  adjustSelection elem, ->
    $(elem).replaceSelection(prefix + replacement + postfix)
    $(elem).focus()
    [replacement.length, prefix.length]

# Drag and drop upload handler
bindUploads = (elem, decorator) ->
  uploadBanner = (file) -> "[Uploading \"#{file.name}\"...]"
  startUpload = (file) -> replaceSelection(elem, "", uploadBanner(file) + "\n", "")
  finishUpload = (file, response) ->
    replacedText = $(elem).val().replace(uploadBanner(file), decorator().image(response.url).join(""))
    $(elem).val(replacedText)
  $(elem).filedrop
    allowedfiletypes: ['image/jpeg', 'image/png', 'image/gif']
    maxfiles: 25
    maxfilesize: 2
    paramname: "upload[file]"
    url: "/uploads.json"
    headers:
      "X-CSRF-Token": Sugar.authToken($(elem).closest("form"))
    uploadStarted: (i, file, len) ->
      startUpload file
    uploadFinished: (i, file, response, time) ->
      finishUpload file, response

Sugar.RichTextArea = (textarea, options) ->
  # Only apply it once
  return this if textarea.richtext
  textarea.richtext = true

  formatButton = $("<li class=\"formatting\"><a>Markdown</a></li>")
  toolbar = $("<ul class=\"richTextToolbar clearfix\"></ul>").append(formatButton).insertBefore(textarea)
  emojiBar = $("<ul class=\"emojiBar clearfix\"></ul>").insertBefore(textarea)
  emojiBar.hide()

  decorator = -> new MarkdownDecorator

  if $(textarea).data('formats')
    formats = $(textarea).data('formats').split(" ")
  else
    formats = ["markdown"]

  if $(textarea).data("format-binding")
    format = $(textarea).closest("form").find($(textarea).data("format-binding")).val()

  if $(textarea).data("remember-format")
    if Sugar.Configuration.preferredFormat
      format = Sugar.Configuration.preferredFormat

  format ||= formats[0]

  setFormat = (newFormat, skipUpdate) ->
    format = newFormat
    if format == "markdown"
      label = "Markdown"
      decorator = -> new MarkdownDecorator
    else if format == "html"
      label = "HTML"
      decorator = -> new HtmlDecorator

    formatButton.find("a").html(label)

    # Update the bound form field
    if $(textarea).data("format-binding")
      $(textarea).closest("form").find($(textarea).data("format-binding")).val(format)

    # Update the user preferences
    if $(textarea).data("remember-format") && !skipUpdate
      if currentUser = Sugar.getCurrentUser()
        currentUser.save("preferred_format", format, {patch: true})

  nextFormat = ->
    setFormat formats[(formats.indexOf(format) + 1) % formats.length]

  setFormat(format, true)

  formatButton.find("a").click -> nextFormat()

  addButton = (name, className, callback) ->
    link = $("<a title=\"#{name}\" class=\"#{className}\"><i class=\"icon-#{className}\"></i></a>")

    link.click ->
      [prefix, replacement, postfix] = callback(getSelection(textarea))
      replaceSelection(textarea, prefix, replacement, postfix)

    $("<li class=\"button\"></li>").append(link).insertBefore(formatButton)

  # Bold button
  addButton "Bold", "bold", (selection) -> decorator().bold(selection)

  # Italic button
  addButton "Italics", "italic", (selection) -> decorator().emphasis(selection)

  # Link button
  addButton "Link", "link", (selection) ->
    url = prompt("Enter link URL", "")
    name = if selection.length > 0 then selection else "Link text"
    url = if url.length > 0 then url else "http://example.com/"
    url = url.replace(/^(?!(f|ht)tps?:\/\/)/, 'http://')
    decorator().link(url, name)

  # Image tag
  addButton "Image", "picture", (selection) ->
    url = if selection.length > 0 then selection else prompt("Enter image URL", "")
    decorator().image(url)

    # Youtube tag
  addButton "Youtube", "youtube", (selection) ->
    url = if selection.length > 0 then selection else prompt("Enter video URL", "")
    decorator().youtube(url)

  # Block Quote
  addButton "Block Quote", "quote-left", (selection) -> decorator().blockquote(selection)

  # Code button
  addButton "Code", "code", (selection) ->
    lang = prompt("Enter language (leave blank for no syntax highlighting)", "")
    decorator().code(selection, lang)

  # Spoiler button
  addButton "Spoiler", "warning-sign", (selection) -> decorator().spoiler(selection)

  # Emoticons
  addButton "Emoticons", "smile", (selection) ->
    emojiBar.slideToggle(100)
    ["", selection, ""]

  # Quoting
  $(Sugar).on "quote", (event, data) ->
    [prefix, replacement, postfix] = decorator().quote(
      data.text,
      data.html,
      data.username,
      data.permalink
    )
    replaceSelection(textarea, prefix, replacement, postfix)

    # Scroll to the bottom of the textarea
    textarea.scrollTop = textarea.scrollHeight

  # Emoticons
  addEmojiButton = (name, image) ->
    link = $("<a title=\"#{name}\"><img alt=\"#{name}\" class=\"emoji\" src=\"#{image}\" width=\"16\" height=\"16\"></a>")
    link.click -> replaceSelection(textarea, "", ":" + name + ": ", "")
    $("<li class=\"button\"></li>").append(link).appendTo(emojiBar)

  addEmojiButton(e.name, e.image) for e in Sugar.Configuration.emoticons

  bindUploads(textarea, decorator) if Sugar.Configuration.uploads

$(Sugar).bind 'ready modified', ->
  $('textarea.rich').each -> new Sugar.RichTextArea(this)
