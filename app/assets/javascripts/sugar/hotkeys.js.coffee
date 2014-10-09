currentTarget = null
keySequence = ''
keySequences = []

specialKeys = [
  8, 9, 13, 19, 20, 27, 32, 33, 34, 35, 36, 37, 38, 39, 40, 45, 46, 96, 97,
  98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 110, 111, 112, 113,
  114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 144, 145, 191
]

bindRawKey = (hotkey, fn) -> $(document).bind 'keydown', hotkey, fn

bindKey = (hotkey, fn) -> bindRawKey hotkey, (event) -> fn(event) if not event.metaKey

bindKeySequence = (expression, fn) -> keySequences.push([expression, fn])

clearNewPostsFromDiscussion = (target) ->
  $('.discussion' + exchangeId(target)).removeClass 'new_posts'
  $('.discussion' + exchangeId(target) + ' .new_posts').html ''

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

focusElement = (event, selector) ->
  $(selector).focus()
  event.preventDefault()

isDiscussion = (target) -> $(target).closest('tr').hasClass('discussion')

keypressToCharacter = (event) ->
  return if event.which in specialKeys
  if event.shiftKey and event.which >= 65 and event.which <= 90
    String.fromCharCode(event.keyCode).toUpperCase()
  else
    String.fromCharCode(event.keyCode).toLowerCase()

markAsRead = (target) ->
  if isDiscussion(target)
    $.get '/discussions/' + exchangeId(target) + '/mark_as_read', {}, ->
      clearNewPostsFromDiscussion(target)

openTarget = (target) -> visitPath(targetUrl(target))
openTargetNewTab = (target) -> window.open targetUrl(target)

scrollToTarget = (target) -> $.scrollTo target, { duration: 100, offset: { top: -50 }, axis: 'y' }

targetUrl = (target) -> target.href

isDiscussion = (target) -> $(target).closest('tr').hasClass('discussion')

isExchangesView = -> $('table.discussions').length > 0
isPostsView     = -> $('.posts .post').length > 0

onlyExchanges = (fn) -> (fn() if isExchangesView())
onlyPosts     = (fn) -> (fn() if isPostsView())

visitPath = (path)     -> document.location = path
visitLink = (selector) -> visitPath($(selector).get(0).href) if $(selector).length > 0

trackKeySequence = (event) ->
  target = $(event.target)
  if target.is('input') or target.is('textarea') or target.is('select')
    keySequence = ''
  else
    character = keypressToCharacter(event)
    if not event.metaKey and character and character.match(/^[\w\d]$/)
      keySequence += character
      keySequence = keySequence.match(/([\w\d]{0,5})$/)[1]
      for [expression, fn] in keySequences
        fn() if keySequence.match(expression)

markTarget = (target) ->
  if isExchangesView()
    $('tr.discussion').removeClass 'targeted'
    $('tr.conversation').removeClass 'targeted'
    $('tr.discussion' + exchangeId(target)).addClass 'targeted'
    $('tr.conversation' + exchangeId(target)).addClass 'targeted'
  else
    $(targets()).removeClass 'targeted'
    $(target).addClass 'targeted'
  scrollToTarget(target) if elemOutOfWindow(target)

targets = -> $('table.discussions td.name a').get().concat $('.posts .post').get()

withTarget = (fn) -> (fn(currentTarget) if currentTarget)

ifTargets = (fn) -> (fn() if targets().length > 0)

first = (collection) -> collection[0]
last  = (collection) -> collection[-1..]

getRelative = (collection, item, offset) ->
  collection[(collection.indexOf(item) + offset + collection.length) % collection.length]

nextTarget = ->
  getRelative targets(), (currentTarget || defaultTarget() || last(targets())), 1

previousTarget = ->
  getRelative targets(), (currentTarget || defaultTarget() || first(targets())), -1

setTarget = (target) ->
  currentTarget = target
  markTarget(target)

resetTarget = -> currentTarget = null

$(document).bind 'keydown', trackKeySequence

bindKeySequence /gd$/, -> visitPath('/discussions')
bindKeySequence /gf$/, -> visitPath('/discussions/following')
bindKeySequence /gF$/, -> visitPath('/discussions/favorites')
bindKeySequence /gc$/, -> visitPath('/discussions/conversations')
bindKeySequence /gi$/, -> visitPath('/invites')
bindKeySequence /gu$/, -> visitPath('/users/online')

bindKey 'shift+p', -> visitLink('.prev_page_link')
bindKey 'shift+k', -> visitLink('.prev_page_link')
bindKey 'shift+n', -> visitLink('.next_page_link')
bindKey 'u',       -> visitLink('#back_link')
bindKey 'shift+j', -> visitLink('.next_page_link')

bindKey '/', (event) -> focusElement(event, '#q')

bindKey 'p', -> ifTargets -> setTarget previousTarget()
bindKey 'k', -> ifTargets -> setTarget previousTarget()
bindKey 'n', -> ifTargets -> setTarget nextTarget()
bindKey 'j', -> ifTargets -> setTarget nextTarget()

bindKey 'r', -> onlyPosts -> Sugar.loadNewPosts()
bindKey 'q', -> onlyPosts -> withTarget (target) -> Sugar.quotePost(target)

bindKey 'o',            -> onlyExchanges -> withTarget (target) -> openTarget(target)
bindKey 'shift+o',      -> onlyExchanges -> withTarget (target) -> openTargetNewTab(target)
bindKey 'Return',       -> onlyExchanges -> withTarget (target) -> openTarget(target)
bindKey 'shift+Return', -> onlyExchanges -> withTarget (target) -> openTargetNewTab(target)
bindKey 'y',            -> onlyExchanges -> withTarget (target) -> markAsRead(target)
bindKey 'm',            -> onlyExchanges -> withTarget (target) -> markAsRead(target)

bindKey 'c', (event) ->
  onlyExchanges -> visitLink('.functions .create')
  onlyPosts     -> focusElement(event, '#compose-body')

$(Sugar).bind 'ready', -> resetTarget()
