$(Sugar).bind "ready", ->
  @Hotkeys.apply()

Sugar.Hotkeys =
  defaultTarget: false
  targets: []
  currentTarget: false
  keySequence: ""
  specialKeys:
    27: "esc"
    9: "tab"
    32: "space"
    13: "return"
    8: "backspace"
    145: "scroll"
    20: "capslock"
    144: "numlock"
    19: "pause"
    45: "insert"
    36: "home"
    46: "del"
    35: "end"
    33: "pageup"
    34: "pagedown"
    37: "left"
    38: "up"
    39: "right"
    40: "down"
    112: "f1"
    113: "f2"
    114: "f3"
    115: "f4"
    116: "f5"
    117: "f6"
    118: "f7"
    119: "f8"
    120: "f9"
    121: "f10"
    122: "f11"
    123: "f12"
    191: "/"
    96: "0"
    97: "1"
    98: "2"
    99: "3"
    100: "4"
    101: "5"
    102: "6"
    103: "7"
    104: "8"
    105: "9"
    106: "*"
    107: "+"
    109: "-"
    110: "."
    111: "/"

  # Apply functionality
  apply: ->
    if $("table.discussions").length > 0
      @setup.discussionsNavigation()
      @setup.discussionsFunctions()
    if $(".posts .post").length > 0
      @setup.postsNavigation()
      @setup.postsFunctions()
    @setup.global()
    @setup.sequences()
    Sugar.log "Hotkeys: Loaded, " + @targets.length + " targets detected."

  # Add target to list
  addTarget: (target, targetId) ->
    if $.inArray(target, @targets) < 0
      $(target).data "targetId", targetId
      @targets[@targets.length] = target

  # Get current target
  getTarget: ->
    (if (@currentTarget) then @currentTarget else false)

  # Scroll to target
  scrollTo: (target) ->
    targetPosition = $(target).offset().top
    bottom = $(window).height() + $(window).scrollTop()
    if targetPosition > bottom or targetPosition < $(window).scrollTop() or (targetPosition + $(target).height()) > bottom
      $.scrollTo target,
        duration: 100
        offset:
          top: -50
          left: 0

        axis: "y"

  # Go to specific target
  gotoTarget: (target) ->
    @currentTarget = target
    $(this).trigger "targetchanged", [ target ]

  # Go to next target
  gotoNextTarget: ->
    unless @currentTarget
      if @defaultTarget
        @gotoTarget @defaultTarget
      else
        @gotoTarget @targets[0]
    else
      index = $.inArray(@currentTarget, @targets) + 1
      index = 0  if index >= @targets.length
      @gotoTarget @targets[index]

  # Go to previous target
  gotoPrevTarget: ->
    unless @currentTarget
      if @defaultTarget
        @gotoTarget @defaultTarget
        @gotoPrevTarget()
      else
        @gotoTarget @targets[@targets.length - 1]
    else
      index = $.inArray(@currentTarget, @targets) - 1
      index = @targets.length - 1  if index < 0
      @gotoTarget @targets[index]

  setup:

    # Global hotkeys
    global: ->
      gotoPrevPage = (event) ->
        document.location = $(".prev_page_link").get(0).href  if not event.metaKey and $(".prev_page_link").length > 0

      gotoNextPage = (event) ->
        document.location = $(".next_page_link").get(0).href  if not event.metaKey and $(".next_page_link").length > 0

      $(document).bind "keydown", "shift+p", gotoPrevPage
      $(document).bind "keydown", "shift+k", gotoPrevPage
      $(document).bind "keydown", "shift+n", gotoNextPage
      $(document).bind "keydown", "shift+j", gotoNextPage
      $(document).bind "keydown", "u", (event) ->
        if not event.metaKey and $("#back_link").length > 0
          document.location = $("#back_link").get(0).href
          false

    # Listen for sequences
    sequences: ->
      $(document).bind "keydown", (event) ->
        target = $(event.target)
        character = not Sugar.Hotkeys.specialKeys[event.which] and String.fromCharCode(event.keyCode).toLowerCase()
        character = character.toUpperCase()  if event.shiftKey and event.which >= 65 and event.which <= 90
        if target.is("input") or target.is("textarea") or target.is("select")
          Sugar.Hotkeys.keySequence = ""
        else
          if not event.metaKey and character and character.match(/^[\w\d]$/)
            Sugar.Hotkeys.keySequence += character
            keySequence = Sugar.Hotkeys.keySequence = Sugar.Hotkeys.keySequence.match(/([\w\d]{0,5})$/)[1]
            shortcuts =
              "#discussions_link": /gd$/
              "#following_link": /gf$/
              "#favorites_link": /gF$/
              "#conversations_link": /gc$/
              "#messages_link": /gm$/
              "#invites_link": /gi$/
              "#users_link": /gu$/

            for selector of shortcuts
              document.location = $(selector).get(0).href  if keySequence.match(shortcuts[selector]) and $(selector).length > 0

    # Navigating posts
    postsNavigation: ->
      # Find targets
      $(".posts .post").each ->
        Sugar.Hotkeys.addTarget this, @id.match(/(post|message)\-([\d]+)/)[2]

      # Detect new posts
      $(Sugar).bind "postsloaded", ->
        $(".posts .post").each ->
          Sugar.Hotkeys.addTarget this, @id.match(/(post|message)\-([\d]+)/)[1]  if @id.match(/(post|message)\-([\d]+)/)

      # Set default target
      if document.location.toString().match(/#(post|message)-([\d]+)/)
        Sugar.Hotkeys.defaultTarget = $("#post-" + document.location.toString().match(/#(post|message)-([\d]+)/)[2]).get(0)
      else
        Sugar.Hotkeys.defaultTarget = $(".posts > .post").get(0)

      # Target change event
      $(Sugar.Hotkeys).bind "targetchanged", (e, target) ->
        $(".posts .post").removeClass "targeted"
        $(target).addClass "targeted"
        @scrollTo target

      # Keyboard bindings
      $(document).bind "keydown", "p", (event) ->
        Sugar.Hotkeys.gotoPrevTarget()  unless event.metaKey

      $(document).bind "keydown", "k", (event) ->
        Sugar.Hotkeys.gotoPrevTarget()  unless event.metaKey

      $(document).bind "keydown", "n", (event) ->
        Sugar.Hotkeys.gotoNextTarget()  unless event.metaKey

      $(document).bind "keydown", "j", (event) ->
        Sugar.Hotkeys.gotoNextTarget()  unless event.metaKey

      $(document).bind "keydown", "/", (event) ->
        #('#q').trigger 'focus'  unless event.metaKey

    # Post functions
    postsFunctions: ->
      # Load new posts
      $(document).bind "keydown", "r", (event) ->
        Sugar.loadNewPosts()  unless event.metaKey

      # Compose
      $(document).bind "keydown", "c", (event) ->
        unless event.metaKey
          Sugar.compose()
          false

      # Quote post
      $(document).bind "keydown", "q", (event) ->
        if not event.metaKey and Sugar.Hotkeys.getTarget()
          Sugar.quotePost Sugar.Hotkeys.getTarget()
          false

    # Navigating discussions
    discussionsNavigation: ->
      $("table.discussions td.name a").each ->
        Sugar.Hotkeys.addTarget this, @parentNode.parentNode.parentNode.className.match(/(discussion|conversation)([\d]+)/)[2]

      # Target change event
      $(Sugar.Hotkeys).bind "targetchanged", (e, target) ->
        $("tr.discussion").removeClass "targeted"
        $("tr.discussion" + $(target).data("targetId")).addClass "targeted"
        $("tr.conversation").removeClass "targeted"
        $("tr.conversation" + $(target).data("targetId")).addClass "targeted"
        @scrollTo target

      # Keyboard bindings
      $(document).bind "keydown", "p", (event) ->
        Sugar.Hotkeys.gotoPrevTarget()  unless event.metaKey

      $(document).bind "keydown", "k", (event) ->
        Sugar.Hotkeys.gotoPrevTarget()  unless event.metaKey

      $(document).bind "keydown", "n", (event) ->
        Sugar.Hotkeys.gotoNextTarget()  unless event.metaKey

      $(document).bind "keydown", "j", (event) ->
        Sugar.Hotkeys.gotoNextTarget()  unless event.metaKey

      $(document).bind "keydown", "/", (event) ->
        #('#q').trigger 'focus'  unless event.metaKey

    # Discussion functions
    discussionsFunctions: ->
      # Open target
      openTarget = (openInNewTab) ->
        if Sugar.Hotkeys.currentTarget
          targetUrl = Sugar.Hotkeys.currentTarget.href
          if openInNewTab
            window.open targetUrl
          else
            document.location = targetUrl

      $(document).bind "keydown", "o", (event) ->
        openTarget false  unless event.metaKey

      $(document).bind "keydown", "shift+o", (event) ->
        openTarget true  unless event.metaKey

      $(document).bind "keydown", "Return", (event) ->
        openTarget false  unless event.metaKey

      $(document).bind "keydown", "shift+Return", (event) ->
        openTarget true  unless event.metaKey

      # Mark a discussion read
      markAsRead = (event) ->
        if not event.metaKey and Sugar.Hotkeys.currentTarget and $(Sugar.Hotkeys.currentTarget.parentNode.parentNode).hasClass("discussion")
          target = Sugar.Hotkeys.currentTarget
          targetId = $(target).data("targetId")
          url = "/discussions/" + targetId + "/mark_as_read"
          $.get url, {}, ->
            $(".discussion" + targetId).removeClass "new_posts"
            $(".discussion" + targetId + " .new_posts").html ""

      $(document).bind "keydown", "y", markAsRead
      $(document).bind "keydown", "m", markAsRead

      # Create a new discussoin
      $(document).bind "keydown", "c", (event) ->
        document.location = $(".functions .create").get(0).href  if not event.metaKey and $(".functions .create").length > 0
