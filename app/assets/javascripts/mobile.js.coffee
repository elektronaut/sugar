#= require jquery
#= require jquery_ujs
#= require underscore
#= require backbone
#= require backbone_rails_sync
#= require backbone_datalink

#= require vendor/jquery.timeago

#= require backbone/sugar
#= require sugar
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

getImageSize = (img) ->
  unless img.originalWidth
    if $(img).attr('width')
      img.originalWidth = parseInt($(img).attr('width'), 10)
    else if $(img).width() > 0
      img.originalWidth = $(img).width()

  unless img.originalHeight
    if $(img).attr('height')
      img.originalHeight = parseInt($(img).attr('height'), 10)
    else if $(img).height() > 0
      img.originalHeight = $(img).height()

  return (img.originalWidth && img.originalWidth > 0 && img.originalHeight && img.originalHeight > 0)

resizeImage = (img) ->
  maxWidth = $(document).width()
  if $(img).parent().width() < maxWidth
    maxWidth = $(img).parent().width()
  img.proportions ||= img.originalWidth / img.originalHeight
  if img.originalWidth > maxWidth
    $(img).css
      width:  maxWidth + 'px'
      height: parseInt((maxWidth / img.proportions), 10) + 'px'

resizeImages = ->
  $(".post .body img").each ->
    img = this
    if getImageSize(img)
      resizeImage(img)
    else
      img.resizeInterval ||= setInterval ->
        if getImageSize(img)
          clearInterval(img.resizeInterval)
          resizeImage(img)
      , 500

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

parsePost = (body) ->
  # Embed Instagram photos directly when a share URL is pasted
  body = body.replace(
    /\b(https?:\/\/instagr\.am\/p\/[^\/]+)\/?(\s|$)/g,
    '<a href="\$1"><img width="612" height="612" src="\$1/media?size=l"></a>\$2'
  )
  return body

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

  # Larger click targets on discussion overview
  $(".discussions .discussion h2 a").each ->
    url = @href
    $(@parentNode.parentNode).click ->
      document.location = url

  # Scroll past the Safari chrome
  unless document.location.toString().match(/\#/)
    setTimeout scrollTo, 100, 0, 1

  # Search mode
  $("#search_mode").change ->
    @parentNode.action = @value

  # Post quoting
  $(".post .functions a.quote_post").click ->
    postId = @id.match(/-([\d]+)$/)[1]
    window.quotePost postId
    false

  # Posting
  $('form.new_post').submit ->
    $body = $(this).find('#reply-body')
    $body.val(parsePost($body.val()))
    true

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

  # Amazon Associates referral code
  if referral_id = Sugar.Configuration.AmazonAssociatesId
    $('.post .body a').each ->
      link = this
      if !$.data(link, 'amazon_associates_referral_id') && link.href.match /https?:\/\/([\w\d\-\.])*amazon\.com/
        $.data(link, 'amazon_associates_referral_id', referral_id)
        return if link.href.match /(\?|&)tag=/

        link.href += if link.href.match(/\?/) then '&' else '?'
        link.href += 'tag=' + referral_id

  # Confirm regular site
  $('a.regular_site').click ->
    return confirm('Are you sure you want to navigate away from the mobile version?')

  resizeYoutube()
  Sugar.init()
