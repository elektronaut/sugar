#= require jquery
#= require jquery_ujs
#= require underscore
#= require backbone
#= require backbone_rails_sync
#= require backbone_datalink

#= require vendor/jquery.timeago

#= require backbone/sugar
#= require sugar
#= require sugar/posts/amazon_associates
#= require sugar/timestamps

window.toggleNavigation = ->
  $("#navigation").toggleClass "active"
  false

resizeYoutube = ->
  $("embed[src*=\"youtube.com\"], iframe[src*=\"youtube.com\"], iframe[src*=\"vimeo.com\"]").each ->
    @originalHeight = @height  unless @originalHeight
    @originalWidth = @width  unless @originalWidth
    maxWidth = window.innerWidth - 20
    maxHeight = window.innerHeight - 20
    maxWidth = @originalWidth  if maxWidth > @originalWidth
    maxHeight = @originalHeight  if maxHeight > @originalHeight
    newWidth = maxWidth
    newHeight = Math.floor(@originalHeight * (newWidth / @originalWidth))
    if newHeight > maxHeight
      newHeight = maxHeight
      newWidth = Math.floor(@originalWidth * (newHeight / @originalHeight))
    @width = newWidth
    @height = newHeight

checkWindowOrientation = ->
  if window.innerWidth isnt currentWidth
    currentWidth = window.innerWidth
    currentHeight = window.innerHeight
    orient = (if (currentWidth < currentHeight) then "profile" else "landscape")
    document.body.setAttribute "orient", orient
    resizeYoutube()

# Hide images in posts by default
hideImagesInPosts = ->
  $(".post .body img").each ->
    @originalSrc = @src
    @linkTarget = @src
    @removeAttribute "height"
    if @parentNode.tagName is "A"
      @linkTarget = @parentNode.href
      $(@parentNode).replaceWith this

  $(".post .body img").wrap "<div class=\"imageloader\"></div>"
  $(".post .body img").each ->
    @parentNode.image = this
    @parentNode.originalSrc = @src
    @src = "/images/blank.gif"
    $(this).click ->
      window.location = @linkTarget

  $(".post .body .imageloader").click ->
    $(this).removeClass "imageloader"
    @image.src = @image.originalSrc

window.addToReply = (string) ->
  jQuery("#reply-body").val jQuery("#reply-body").val() + string

# Post quoting
window.quotePost = (postId) ->
  postDiv = "#post-" + postId
  if $(postDiv).length > 0
    permalink = jQuery(postDiv + " .post_info .permalink a").get()[0].href.replace(/^https?:\/\/([\w\d\.:\-]*)/, "")
    username = jQuery(postDiv + " .post_info .username a").text()
    content = jQuery(postDiv + " .body").html().replace(/^[\s]*/, "").replace(/[\s]*$/, "").replace(/<br[\s\/]*>/g, "\n")
    quotedPost = "<blockquote><cite>Posted by <a href=\"" + permalink + "\">" + username + "</a>:</cite>" + content + "</blockquote>"
    window.addToReply quotedPost

currentWidth = 0
currentHeight = 0
setTimeout checkWindowOrientation, 0
checkTimer = setInterval(checkWindowOrientation, 300)
$(document).ready ->

  hideImagesInPosts()

  # Larger click targets on discussion overview
  $(".discussions .discussion h2 a").each ->
    url = @href
    $(@parentNode.parentNode).click ->
      document.location = url

  if document.location.toString().match(/\#/)
    setTimeout (->
      anchorName = document.location.toString().match(/\#([\w\d\-_]+)/)[1]
      scrollPosition = $("#" + anchorName).offset().top
      scrollTo 0, scrollPosition
    ), 1000
  else
    # Scroll to top w/o location bar unless targeting an anchor
    setTimeout scrollTo, 100, 0, 1

  jQuery("#search_mode").change ->
    @parentNode.action = @value

  # Post quoting
  $(".post .functions a.quote_post").click ->
    postId = @id.match(/-([\d]+)$/)[1]
    window.quotePost postId
    false

  # Spoiler tags
  $(".spoiler").each ->
    container = this
    unless container.spoilerApplied
      $(container).wrapInner "<span class=\"innerSpoiler\"></span>"  if $(container).find(".innerSpoiler").length < 1
      $(container).prepend "<span class=\"spoilerLabel\">Spoiler!</span> "  if $(container).find(".spoilerLabel").length < 1
      $(container).find(".innerSpoiler").hide()
      $(container).click ->
        $(container).find(".innerSpoiler").show()
        $(container).find(".spoilerLabel").hide()

      container.spoilerApplied = true

  resizeYoutube()
  Sugar.init()