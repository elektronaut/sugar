currentTarget = null
targets = []
changeCallback = (target) ->

keySequence = ""
keySequences = []
specialKeys = [
  8, 9, 13, 19, 20, 27, 32, 33, 34, 35, 36, 37, 38, 39, 40, 45, 46, 96, 97,
  98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 110, 111, 112, 113,
  114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 144, 145, 191
]

bindHotkey = (hotkey, fn) -> $(document).bind "keydown", hotkey, fn

bindHotkeyWithoutMeta = (hotkey, fn) -> bindHotkey hotkey, (event) -> fn(event) if not event.metaKey

bindKeySequence = (expression, fn) -> keySequences.push([expression, fn])

clearNewPostsFromDiscussion = (target) ->
  $(".discussion" + exchangeId(target)).removeClass "new_posts"
  $(".discussion" + exchangeId(target) + " .new_posts").html ""

defaultTarget = ->
  if document.location.hash && document.location.hash.match(/^#post-([\d]+)$/)
    postId = document.location.hash.match(/^#post-([\d]+)$/)[1]
    $('.post[data-post_id=' + postId + ']').get(0)

elemOutOfWindow = (elem) ->
  elemTop    = $(elem).offset().top
  elemBottom = elemTop + $(elem).height()
  top        = $(window).scrollTop()
  bottom     = top + $(window).height()
  (elemTop < top) or (elemBottom > bottom)

exchangeId = (target) -> $(target).closest('tr').data('exchange-id')

isDiscussion = (target) -> $(target).closest('tr').hasClass("discussion")

keypressToCharacter = (event) ->
  return if event.which in specialKeys
  if event.shiftKey and event.which >= 65 and event.which <= 90
    String.fromCharCode(event.keyCode).toUpperCase()
  else
    String.fromCharCode(event.keyCode).toLowerCase()

markAsRead = (target) ->
  if isDiscussion(target)
    $.get "/discussions/" + exchangeId(target) + "/mark_as_read", {}, ->
      clearNewPostsFromDiscussion(target)

openTarget = (target) -> visitPath(targetUrl(target))
openTargetNewTab = (target) -> window.open targetUrl(target)

scrollToTarget = (target) -> $.scrollTo target, { duration: 100, offset: { top: -50 }, axis: "y" }

targetUrl = (target) -> target.href

isDiscussion = (target) -> $(target).closest('tr').hasClass("discussion")

isExchangesView = -> $("table.discussions").length > 0
isPostsView     = -> $(".posts .post").length > 0

onlyExchanges = (fn) -> (fn() if isExchangesView())
onlyPosts     = (fn) -> (fn() if isPostsView())

visitPath = (path)     -> document.location = path
visitLink = (selector) -> visitPath($(selector).get(0).href) if $(selector).length > 0

trackKeySequence = (event) ->
  target = $(event.target)
  if target.is("input") or target.is("textarea") or target.is("select")
    keySequence = ""
  else
    character = keypressToCharacter(event)
    if not event.metaKey and character and character.match(/^[\w\d]$/)
      keySequence += character
      keySequence = keySequence.match(/([\w\d]{0,5})$/)[1]
      for [expression, fn] in keySequences
        fn() if keySequence.match(expression)

withTarget = (fn) -> (fn(currentTarget) if currentTarget)

markTarget = (target) ->
  if isExchangesView()
    $("tr.discussion").removeClass "targeted"
    $("tr.conversation").removeClass "targeted"
    $("tr.discussion" + exchangeId(target)).addClass "targeted"
    $("tr.conversation" + exchangeId(target)).addClass "targeted"
  else
    $(targets).removeClass "targeted"
    $(target).addClass "targeted"
  scrollToTarget(target) if elemOutOfWindow(target)

addTarget = (target) -> (targets.push(target) unless target in targets)

setTarget = (target) ->
  currentTarget = target
  markTarget(target)

nextTarget = ->
  if currentTarget
    index = targets.indexOf(currentTarget) + 1
    index = 0 if index >= targets.length
    targets[index]
  else if defaultTarget()
    defaultTarget()
  else if targets.length > 0
    targets[0]

previousTarget = ->
  if currentTarget
    index = targets.indexOf(currentTarget) - 1
    index = targets.length - 1 if index < 0
    targets[index]
  else if defaultTarget()
    index = targets.indexOf(defaultTarget()) - 1
    index = targets.length - 1 if index < 0
    targets[index]
  else if targets.length > 0
    targets[targets.length - 1]

resetTargets = ->
  targets = []
  currentTarget = null

detectTargets = ->
  $("table.discussions td.name a").each -> addTarget this
  $(".posts .post").each -> addTarget this


$(document).bind "keydown", trackKeySequence

bindKeySequence /gd$/, -> visitPath('/discussions')
bindKeySequence /gf$/, -> visitPath('/discussions/following')
bindKeySequence /gF$/, -> visitPath('/discussions/favorites')
bindKeySequence /gc$/, -> visitPath('/discussions/conversations')
bindKeySequence /gi$/, -> visitPath('/invites')
bindKeySequence /gu$/, -> visitPath('/users/online')

bindHotkeyWithoutMeta "shift+p", (event) -> visitLink('.prev_page_link')
bindHotkeyWithoutMeta "shift+k", (event) -> visitLink('.prev_page_link')
bindHotkeyWithoutMeta "shift+n", (event) -> visitLink('.next_page_link')
bindHotkeyWithoutMeta "u",       (event) -> visitLink('#back_link')
bindHotkeyWithoutMeta "shift+j", (event) -> visitLink('.next_page_link')

bindHotkey "/", (event) ->
  $('#q').focus()
  event.preventDefault()

bindHotkeyWithoutMeta "p", (event) -> setTarget previousTarget()
bindHotkeyWithoutMeta "k", (event) -> setTarget previousTarget()
bindHotkeyWithoutMeta "n", (event) -> setTarget nextTarget()
bindHotkeyWithoutMeta "j", (event) -> setTarget nextTarget()

bindHotkeyWithoutMeta "r", (event) -> onlyPosts -> Sugar.loadNewPosts()
bindHotkeyWithoutMeta "q", (event) -> onlyPosts -> withTarget (target) -> Sugar.quotePost(target)

bindHotkeyWithoutMeta "o",            (event) -> onlyExchanges -> withTarget (target) -> openTarget(target)
bindHotkeyWithoutMeta "shift+o",      (event) -> onlyExchanges -> withTarget (target) -> openTargetNewTab(target)
bindHotkeyWithoutMeta "Return",       (event) -> onlyExchanges -> withTarget (target) -> openTarget(target)
bindHotkeyWithoutMeta "shift+Return", (event) -> onlyExchanges -> withTarget (target) -> openTargetNewTab(target)
bindHotkeyWithoutMeta "y",            (event) -> onlyExchanges -> withTarget (target) -> markAsRead(target)
bindHotkeyWithoutMeta "m",            (event) -> onlyExchanges -> withTarget (target) -> markAsRead(target)

bindHotkeyWithoutMeta "c", (event) ->
  onlyExchanges -> visitLink('.functions .create')
  onlyPosts ->
    $("#compose-body").focus()
    event.preventDefault()

$(Sugar).bind "ready", ->
  resetTargets()
  detectTargets()

$(Sugar).bind "postsloaded", -> detectTargets()
