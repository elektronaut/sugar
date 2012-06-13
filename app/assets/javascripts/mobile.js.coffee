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
    maxWidth = $(this).closest('.body').width()
    @proportions ||= $(this).width() / $(this).height()
    @width = maxWidth
    @height = maxWidth / @proportions

resizeImages = ->
  $(".post .body img").each ->
    maxWidth = $(this).parent().width()
    @originalWidth ||= $(this).width()
    @proportions ||= $(this).width() / $(this).height()
    if @originalWidth > maxWidth
      $(this).css
        width: maxWidth + 'px'
        height: (maxWidth / @proportions) + 'px'

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

$(document).ready ->

  updateLayout = ->
    if window.orientation?
      if window.orientation == 90 || window.orientation == -90
        document.body.setAttribute "orient", "landscape"
      else
        document.body.setAttribute "orient", "portrait"
    resizeYoutube()
    resizeImages()

  $(window).bind 'orientationchange', updateLayout
  $(window).bind 'resize', updateLayout
  updateLayout()

  # Open images when clicked
  $('.post .body img').click ->
    document.location = this.src


  #hideImagesInPosts()

  # Larger click targets on discussion overview
  $(".discussions .discussion h2 a").each ->
    url = @href
    $(@parentNode.parentNode).click ->
      document.location = url

  unless document.location.toString().match(/\#/)
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