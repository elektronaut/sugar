$(Sugar).bind('ready modified', function () {
  $('a.button, button').each(function () {
    if ($(this).find('span').length === 0) {
      $(this).wrapInner('<span />');
    }
  });
});

$(Sugar).bind('ready', function () {
  $('table.discussions').each(function () {
    $('#content').css('min-width', $(this).outerWidth() + 'px');
  });

  $('#sidebar').each(function () {
    let minWidth = $('#content').outerWidth() + $('#sidebar').outerWidth();
    $('#wrapper').css('min-width', minWidth + 'px');
  });

  $('#reply-tabs').each(function () {
    window.replyTabs = new Sugar.Tabs(this, { showFirstTab: false });

    if ($('body.last_page').length > 0) {
      window.replyTabs.controls.showTab(window.replyTabs.tabs[0]);
    }

    $('#replyText textarea').on("focus", function () {
      window.replyTabs.controls.showTab(window.replyTabs.tabs[0]);
    });

    $(Sugar).on("quote", function () {
      window.replyTabs.controls.showTab(window.replyTabs.tabs[0]);
    });
  });

  $('#signup-tabs').each(function () {
    new Sugar.Tabs(this, { showFirstTab: true });
  });

  $('.admin.configuration .tabs').each(function () {
    new Sugar.Tabs(this, { showFirstTab: true });
  });
});
