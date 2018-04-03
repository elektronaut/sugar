$(Sugar).bind('ready', function () {
  function previewPost() {
    let postBody   = $("#compose-body").val();
    let format     = $("#compose-body").closest('form').find('.format').val();
    let previewUrl = $("#compose-body").closest('form').data('preview-url');

    $(Sugar).trigger('posting-status', ['Loading preview&hellip;']);

    $(".posts #previewPost").animate({opacity: 0.1}, 'fast');
    $.ajax({
      url: previewUrl,
      type: "POST",
      data: {
        "post[body]": postBody,
        "post[format]": format,
        authenticity_token: Sugar.authToken()
      },

      success: function (previewPost) {
        // Inject the #ajaxPosts container so new posts
        // will be loaded above the prewview
        if ($(".posts #ajaxPosts").length < 1) {
          $(".posts").append("<div id=\"ajaxPosts\"></div>");
        }

        // Create the container
        if ($(".posts #previewPost").length < 1) {
          $(".posts").append("<div id=\"previewPost\"></div>");
        }

        $(".posts #previewPost").html(previewPost);

        // Animation
        if ($(".posts #previewPost").hasClass('shown')) {
          $(".posts #previewPost").animate({opacity: 1.0}, 'fast');
        } else {
          $(".posts #previewPost").addClass('shown').hide().fadeIn();
        }

        $(Sugar).trigger(
          'postsloaded',
          [$(".posts #previewPost").find('.post')]
        );
      },

      error: function (xhr) {
        alert("Error: " + xhr.responseText);
      },

      complete: function () {
        $(Sugar).trigger('posting-complete');
      }
    });
  };

  $('#replyText .preview').click(function() {
    previewPost();
  });
});
