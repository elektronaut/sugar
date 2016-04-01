(function() {
  var currentTarget = null;
  var keySequence = '';
  var keySequences = [];

  let indexOf = [].indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (i in this && this[i] === item) return i;
    }
    return -1;
  };

  let specialKeys = [
    8, 9, 13, 19, 20, 27, 32, 33, 34, 35, 36, 37, 38, 39, 40, 45, 46, 96, 97,
    98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 110, 111, 112, 113,
    114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 144, 145, 191
  ];

  let bindRawKey = (hotkey, fn) =>
    $(document).bind('keydown', hotkey, fn);

  let bindKey = (hotkey, fn) =>
    bindRawKey(hotkey, event => { if (!event.metaKey) { return fn(event); } });

  let bindKeySequence = (expression, fn) =>
    keySequences.push([expression, fn]);

  let exchangeId = (target) =>
    $(target).closest('tr').data('exchange-id');

  let clearNewPostsFromDiscussion = (target) => {
    $('.discussion' + exchangeId(target)).removeClass('new_posts');
    $('.discussion' + exchangeId(target) + ' .new_posts').html('');
  };

  let defaultTarget = () => {
    if (document.location.hash &&
        document.location.hash.match(/^#post-([\d]+)$/)) {
      let postId = document.location.hash.match(/^#post-([\d]+)$/)[1];
      return $('.post[data-post_id=' + postId + ']').get(0);
    }
  };

  let elemOutOfWindow = (elem) => {
    let elemTop = $(elem).offset().top;
    let elemBottom = elemTop + $(elem).height();
    let top = $(window).scrollTop();
    let bottom = top + $(window).height();
    return (elemTop < top) || (elemBottom > bottom);
  };

  let focusElement = (event, selector) => {
    $(selector).focus();
    return event.preventDefault();
  };

  let isDiscussion = (target) =>
    $(target).closest('tr').hasClass('discussion');

  let keypressToCharacter = (event) => {
    var ref;
    if (ref = event.which, indexOf.call(specialKeys, ref) >= 0) {
      return;
    }
    if (event.shiftKey && event.which >= 65 && event.which <= 90) {
      return String.fromCharCode(event.keyCode).toUpperCase();
    } else {
      return String.fromCharCode(event.keyCode).toLowerCase();
    }
  };

  let markAsRead = (target) => {
    if (isDiscussion(target)) {
      let path = '/discussions/' + exchangeId(target) + '/mark_as_read';
      $.get(path, {}, function() {
        clearNewPostsFromDiscussion(target);
      });
    }
  };

  let scrollToTarget = (target) =>
    $.scrollTo(target, { duration: 100, offset: { top: -50 }, axis: 'y' });

  let targetUrl = (target) =>
    target.href;

  let isExchangesView = () =>
    $('table.discussions').length > 0;

  let isPostsView = () =>
    $('.posts .post').length > 0;

  let onlyExchanges = (fn) =>
    { if (isExchangesView()) { return fn(); } };

  let onlyPosts = (fn) =>
    { if (isPostsView()) { return fn(); } };

  let visitPath = (path) =>
    document.location = path;

  let visitLink = (selector) => {
    if ($(selector).length > 0) { return visitPath($(selector).get(0).href); }
  };

  let trackKeySequence = (event) => {
    let target = $(event.target);
    if (target.is('input') || target.is('textarea') || target.is('select')) {
      keySequence = '';
    } else {
      let character = keypressToCharacter(event);
      if (!event.metaKey && character && character.match(/^[\w\d]$/)) {
        keySequence += character;
        keySequence = keySequence.match(/([\w\d]{0,5})$/)[1];
        for (var i = 0; i < keySequences.length; i++) {
          let [expression, fn] = keySequences[i];
          if (keySequence.match(expression)) {
            fn();
          }
        }
      }
    }
  };

  let targets = () =>
    $('table.discussions td.name a').get().concat($('.posts .post').get());

  let markTarget = (target) => {
    if (isExchangesView()) {
      $('tr.discussion').removeClass('targeted');
      $('tr.conversation').removeClass('targeted');
      $('tr.discussion' + exchangeId(target)).addClass('targeted');
      $('tr.conversation' + exchangeId(target)).addClass('targeted');
    } else {
      $(targets()).removeClass('targeted');
      $(target).addClass('targeted');
    }
    if (elemOutOfWindow(target)) {
      scrollToTarget(target);
    }
  };

  let withTarget = (fn) =>
    { if (currentTarget) { return fn(currentTarget); } };

  let ifTargets = (fn) =>
    { if (targets().length > 0) { return fn(); } };

  let first = (collection) =>
    collection[0];

  let last = (collection) =>
    collection.slice(-1);

  let getRelative = (collection, item, offset) =>
    collection[(
      collection.indexOf(item) + offset + collection.length
    ) % collection.length];

  let nextTarget = () =>
    getRelative(
      targets(), currentTarget || defaultTarget() || last(targets()), 1
    );

  let previousTarget = () =>
    getRelative(
      targets(), currentTarget || defaultTarget() || first(targets()), -1
    );

  let setTarget = (target) =>
    markTarget(currentTarget = target);

  let resetTarget = () =>
    currentTarget = null;

  let openTarget = (target) =>
    visitPath(targetUrl(target));

  let openTargetNewTab = (target) =>
    window.open(targetUrl(target));

  $(document).bind('keydown', trackKeySequence);

  bindKeySequence(/gd$/, () => visitPath('/discussions'));
  bindKeySequence(/gf$/, () => visitPath('/discussions/following'));
  bindKeySequence(/gF$/, () => visitPath('/discussions/favorites'));
  bindKeySequence(/gc$/, () => visitPath('/discussions/conversations'));
  bindKeySequence(/gi$/, () => visitPath('/invites'));
  bindKeySequence(/gu$/, () => visitPath('/users/online'));

  bindKey('shift+p', () => visitLink('.prev_page_link'));
  bindKey('shift+k', () => visitLink('.prev_page_link'));
  bindKey('shift+n', () => visitLink('.next_page_link'));
  bindKey('u',       () => visitLink('#back_link'));
  bindKey('shift+j', () => visitLink('.next_page_link'));

  bindKey('/', (event) => focusElement(event, '#q'));

  bindKey('p', () => ifTargets(() => setTarget(previousTarget())));
  bindKey('k', () => ifTargets(() => setTarget(previousTarget())));
  bindKey('n', () => ifTargets(() => setTarget(nextTarget())));
  bindKey('j', () => ifTargets(() => setTarget(nextTarget())));

  bindKey('r', () => onlyPosts(() => Sugar.loadNewPosts()));
  bindKey('q', () => onlyPosts(() => withTarget((t) => Sugar.quotePost(t))));

  bindKey('o', () =>
    onlyExchanges(() => withTarget((t) => openTarget(t))));
  bindKey('shift+o', () =>
    onlyExchanges(() => withTarget((t) => openTargetNewTab(t))));
  bindKey('Return', () =>
    onlyExchanges(() => withTarget((t) => openTarget(t))));
  bindKey('shift+Return', () =>
    onlyExchanges(() => withTarget((t) => openTargetNewTab(t))));

  bindKey('y', () => onlyExchanges(() => withTarget((t) => markAsRead(t))));
  bindKey('m', () => onlyExchanges(() => withTarget((t) => markAsRead(t))));

  bindKey('c', (event) => {
    onlyExchanges(() => visitLink('.functions .create'));
    onlyPosts(() => focusElement(event, '#compose-body'));
  });

  $(Sugar).bind('ready', () => resetTarget());
}).call(this);
