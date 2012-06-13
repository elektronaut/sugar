# Listens for a ready event from the framework, trigger init()
# if the application ID is configured.
$(Sugar).bind "ready", ->
  @Facebook.init()  if @Configuration.FacebookAppId

Sugar.Facebook =
  appId: false
  init: ->
    @appId = Sugar.Configuration.FacebookAppId
    if $(".fb_button").length > 0
      $(".fb_button").addClass("fb_button_large").wrapInner "<span class=\"fb_button_text\" />"
      @loadAsync()

  loadAsync: ->
    facebook_lib = this
    #$(this).bind "ready", ->

    window.fbAsyncInit = ->
      FB.init
        appId: Sugar.Facebook.appId
        #status: true # Check login status
        #cookie: true # Enable cookies to allow the server to access the session
        #xfbml:  true # Parse XFBML

    $("body").append "<div id=\"fb-root\" />"
    e = document.createElement("script")
    e.src = document.location.protocol + "//connect.facebook.net/en_US/all.js"
    e.async = true
    document.getElementById("fb-root").appendChild e
