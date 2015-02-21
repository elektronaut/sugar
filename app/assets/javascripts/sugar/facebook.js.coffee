# Listens for a ready event from the framework, trigger init()
# if the application ID is configured.
$(Sugar).bind "ready", ->
  @Facebook.init()  if @Configuration.facebookAppId

Sugar.Facebook =
  appId: false
  apiReady: false

  init: ->
    @appId = Sugar.Configuration.facebookAppId
    if $(".fb_button").length > 0
      $(".fb_button").addClass("fb_button_large").wrapInner "<span class=\"fb_button_text\" />"
    @loadAsync()
    $(Sugar).bind "postsloaded", (event, posts) ->
      Sugar.Facebook.parsePosts(posts)

  withAPI: (callback) ->
    if @apiReady
      callback()
    else
      interval = setInterval =>
        if @apiReady
          clearInterval interval
          callback()
      , 50

  loadAsync: ->
    window.fbAsyncInit = =>
      FB.init
        version: 'v2.0'
        appId:   Sugar.Facebook.appId
        status:  true # Check login status
        cookie:  true # Enable cookies to allow the server to access the session
        xfbml:   true # Parse XFBML
      @apiReady = true

    $("body").append "<div id=\"fb-root\" />"

    fjs = document.getElementsByTagName("script")[0]
    js = document.createElement("script")
    js.id = "facebook-jssdk"
    js.src = "//connect.facebook.net/en_US/sdk.js"
    fjs.parentNode.insertBefore js, fjs

  parsePosts: (posts) ->
    @withAPI -> posts.each ->
      FB.XFBML.parse(this)
