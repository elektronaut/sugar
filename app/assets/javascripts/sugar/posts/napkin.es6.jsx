let napkinObject = () => swfobject.getObjectById("napkin")

let withNapkinObject = function(fn) {
  if (napkinObject()) {
    return fn(napkinObject());
  }
};

// Make drawings clickable
$(Sugar).bind('ready postsloaded', function() {
  $('.drawing img').each(function() {
    if (!$(this).data('napkin_applied')) {
      var img = this;
      $(this).data('napkin_applied', true);
      $(this).click(function() {
        withNapkinObject(o => o.setBackground(img.src));
      });
    }
  });
});

// Drawing upload handler
$(Sugar).bind('ready', function() {
  if ($("#napkin").length > 0) {
    let $buttons = $('#napkin-submit');

    function showStatus(message) {
      $buttons.find('.status').html(message);
      $buttons.find('button').hide();
      $buttons.addClass('posting');
    };

    function clearStatus() {
      $buttons.find('.status').html('');
      $buttons.find('button').fadeIn('fast');
      $buttons.removeClass('posting');
    };

    // Button handler
    $buttons.find('button').click(function() {
      showStatus('Posting, please wait&hellip;');
      withNapkinObject(o => o.uploadDrawing());
    });

    // Callback from napkin
    window.onDrawingUploaded = function() {
      clearStatus();
      window.replyTabs.controls.showTab(window.replyTabs.tabs[0]),
      Sugar.loadNewPosts();
    };
  }
});
