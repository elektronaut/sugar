class Sugar.PostDetector
  @paused      = false
  @endpoint    = null
  @interval    = null
  @total_posts = null
  @read_posts  = null

  @refresh: ->
    unless @endpoint
      @endpoint = $('#discussionLink').get()[0].href
      @endpoint = @endpoint.match(/^(https?:\/\/[\w\d\.:]+\/discussions\/[\d]+)/)[1] + "/posts/count.js"

    unless @paused
      post_detector = this
      $.getJSON @endpoint, (json) ->
        new_posts = json.posts_count - post_detector.total_posts
        if new_posts > 0
          post_detector.total_posts = json.posts_count
          $(Sugar).trigger('newposts', [post_detector.total_posts, new_posts, (post_detector.total_posts - post_detector.read_posts)])

  @start: ->
    @read_posts  ||= parseInt($('.total_items_count').eq(0).text(), 10)
    @total_posts ||= @read_posts
    unless @interval
      @interval = setInterval ->
        Sugar.PostDetector.refresh()
      , 5000

  @stop: ->
    clearInterval @interval
    @interval = null

  @pause: ->
    @paused = true

  @resume: ->
    @paused = false

  @mark_posts_read: (count) ->
    @read_posts += count
    @total_posts = @read_posts if @total_posts < @read_posts


Sugar.loadNewPosts = ->
  if $("#discussionLink").length > 0
    Sugar.PostDetector.pause()
    $(Sugar).trigger 'postsloading'

    endpoint = $("#discussionLink").get()[0].href.match(/^(https?:\/\/[\w\d\.:]+\/discussions\/[\d]+)/)[1]
    endpoint += "/posts/since/" + Sugar.PostDetector.read_posts

    $.get endpoint, (data) ->
      # Create the container if necessary
      if $(".posts #ajaxPosts").length < 1
        $(".posts").append '<div id="ajaxPosts"></div>'

      # Insert the content
      $(".posts #ajaxPosts").append data
      new_posts = $(".posts #ajaxPosts .post:not(.shown)")

      # Animate in the new posts
      new_posts.hide().slideDown().addClass "shown"

      # Update read posts count
      Sugar.PostDetector.mark_posts_read new_posts.length

      Sugar.PostDetector.resume()
      $(Sugar).trigger 'postsloaded', [new_posts]


$(Sugar).bind 'ready', ->

  # Start the post detector
  if $('.total_items_count').length > 0 && $('#newPosts').length > 0 && $('body.last_page').length > 0
    Sugar.PostDetector.start()

  # -- Window title --

  # Update the window title on new posts
  original_document_title = document.title
  $(Sugar).bind 'newposts', (event, total_posts, new_posts, unread_posts) ->
    document.title = "[#{unread_posts} new posts] #{original_document_title}"

  # Reset the document title when posts are loaded
  $(Sugar).bind 'postsloaded', ->
    document.title = original_document_title

  # -- Paginator --

  # Update the total posts count on the paginator
  $(Sugar).bind 'newposts', (event, total_posts) ->
    $('.total_items_count').text total_posts

  # Update the number of shown posts
  $(Sugar).bind 'postsloaded', ->
    $('.shown_items_count').text Sugar.PostDetector.read_posts

  # -- Notification --

  # Show the notification on new posts
  $(Sugar).bind 'newposts', (event, total_posts, new_posts, unread_posts) ->
    if unread_posts == 1
      notification_string = "A new post has been made"
    else
      notification_string = "#{unread_posts} new posts have been made"

    notification_string += ', <a href="' + $('#discussionLink').get()[0].href + '">click here to load</a>.'
    $('#newPosts').html("<p>#{notification_string}</p>")
    $('#newPosts a').click ->
      Sugar.loadNewPosts()
      false

    # Slide the notification in
    unless $('#newPosts').hasClass('new_posts_since_refresh')
      $('#newPosts').addClass('new_posts_since_refresh').hide().slideDown()

  # Show loading status
  $(Sugar).bind 'postsloading', ->
    $('#newPosts').addClass('new_posts_since_refresh').html('Loading&hellip;')

  # Hide when posts are loaded
  $(Sugar).bind 'postsloaded', ->
    $('#newPosts').removeClass('new_posts_since_refresh').html('').hide()
