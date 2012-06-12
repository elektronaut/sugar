$(Sugar).bind('ready', function () {

  // Handle posting
  $("#replyText form").submit(function () {
    return Sugar.parseSubmit(this);
  });

  Sugar.napkin();
});

$.extend(Sugar, {

  napkin : function () {
    if ($('#napkin').length > 0) {
      // Setup callbacks
      window.uploadDrawing = function () {
        $('#napkin-submit').text("Posting, please wait...");
        swfobject.getObjectById("napkin").uploadDrawing();
      };
      window.onDrawingUploaded = function (url) {
        window.location.reload();
      };

      // Make napkins clickable
      $('.drawing img').each(function () {
        $(this).click(function () {
          if (swfobject.getObjectById("napkin")) {
            swfobject.getObjectById("napkin").setBackground(this.src);
          }
        });
      });
    }
  },

  compose: function (options) {
    options = $.extend({}, options);
    if (window.replyTabs) {
      window.replyTabs.controls.showTab(window.replyTabs.tabs[0]);
    }
    $('#replyText textarea').each(function () {
      if (options.add) {
        $(this).val($(this).val() + options.add);
      }
      $(this).focus();
    });
  },

  // ---- Posting ----

  // parseSubmit() reads the contents of the posting textarea and applies it to a hidden div.
  // If there are any images, parseSubmit() will attempt to load them and update the post body
  // with proper width/height attributes.
  parseSubmit : function (submitForm) {
    var postBody = $('#compose-body').val();

    // Abort if the post is empty
    if (postBody.replace(/\s+/, '') == '') {
      return false;
    }

    if ($.browser.msie) {
      // Don't do anything fancy in IE, just submit the post
      // without AJAX.
      $(Sugar).trigger('posting-status', ['Posting&hellip;']);
    } else {
      $(Sugar).trigger('posting-status', ['Validating post&hellip;']);

      // Auto-link URLs
      postBody = postBody.replace(/(^|\s)((ftp|https?):\/\/[^\s]+\b\/?)/gi, "$1<a href=\"$2\">$2</a>");

      if ($('#hiddenPostVerifier').length < 1) {
        $(document.body).append('<div id="hiddenPostVerifier"></div>');
      }
      var postNotifier = $('#hiddenPostVerifier');
      postNotifier.show();
      postNotifier.html(postBody);
      postNotifier.hide();

      // Rewrite local links
      var currentDomain = document.location.toString().match(/^(https?:\/\/[\w\d\-\.:]+)/)[1];
      var postLinks = postNotifier.find('a');
      if (postLinks.length > 0) {
        for (var a = 0; a < postLinks.length; a += 1) {
          postLinks[a].href = postLinks[a].href.replace(currentDomain, '');
        }
        $('#compose-body').val(postNotifier.html());
      }

      // Load images
      var postImages = postNotifier.find('img');
      var loadedImages = [];
      if (postImages.length > 0) {

        // Async loading event
        postImages.each(function () {
          $(this).load(function () {
            loadedImages.push(this);
          });
        });

        // Check loading of images
        postNotifier.cycles = 0;
        postNotifier.loadInterval = setInterval(function () {
          postNotifier.cycles += 1;
          $(Sugar).trigger('posting-status', ['Loading image ' + loadedImages.length + ' of ' + postImages.length + '&hellip;']);

          // Load failed
          if (postNotifier.cycles >= 80) {
            clearInterval(postNotifier.loadInterval);
            if (confirm("One or more of your images timed out. Post anyway?")) {
              $(loadedImages).each(function () {
                $(this).attr('height', this.height);
                $(this).attr('width', this.width);
              });
              $('#compose-body').val(postNotifier.html());
              Sugar.submitPost();
            } else {
              $(Sugar).trigger('posting-complete');
            }
          }

          // All images loaded
          if (loadedImages.length === postImages.length) {
            postImages.each(function () {
              $(this).attr('height', this.height);
              $(this).attr('width', this.width);
            });
            $('#compose-body').val(postNotifier.html());
            clearInterval(postNotifier.loadInterval);
            Sugar.submitPost();
          }
        }, 100);
        return false;
      } else {
        Sugar.submitPost();
        return false;
      }
    }
  },

  // Submits post via AJAX if supported.
  submitPost : function () {
    $("#replyText form").each(function () {
      var submitForm = this;
      $(Sugar).trigger('posting-status', ['Posting, please wait&hellip;']);
      if ($(submitForm).hasClass('livePost')) {
        var postBody = $('#compose-body').val();
        $.ajax({
          url:  submitForm.action,
          type: 'POST',
          data: {
            'post[body]': postBody,
            authenticity_token: Sugar.authToken(this)
          },
          success: function () {
            $('#compose-body').val('');
            $('.posts #previewPost').remove();
            Sugar.loadNewPosts();
          },
          error: function (xhr, textStatus, errorThrown) {
            alert(textStatus);
            if (postBody === "") {
              alert("Your post is empty!");
            } else {
              if (textStatus === 'timeout') {
                alert('Error: The request timed out.');
              } else {
                alert('There was a problem validating your post.');
              }
            }
          },
          complete: function () {
            $(Sugar).trigger('posting-complete');
          }
        });
      } else {
        submitForm.submit();
      }
    });
  }

});
