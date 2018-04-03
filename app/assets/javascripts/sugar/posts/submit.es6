$(Sugar).bind('ready', function () {
  // Submit post via AJAX
  function submitPost(form) {
    $(Sugar).trigger("posting-status", ["Posting, please wait&hellip;"]);

    if ($(form).hasClass("livePost")) {
      let body = $("#compose-body").val();
      let format = $("#compose-body").closest('form').find('.format').val();

      $.ajax({
        url: form.action,
        type: "POST",
        data: {
          "post[body]": body,
          "post[format]": format,
          authenticity_token: Sugar.authToken(),
          format: "json"
        },

        success: function () {
          $("#compose-body").val("");
          $(".posts #previewPost").remove();
          Sugar.loadNewPosts();
        },

        error: function (xhr, text_status) {
          if (body === "") {
            alert("Your post is empty!");
          } else if (text_status === "timeout") {
            alert("Error: The request timed out.");
          } else {
            alert(xhr.responseText);
          }
        },

        complete: function () {
          $(Sugar).trigger("posting-complete");
        }
      });
    } else {
      form.submit();
    }
  };

  // Form event handler
  $("#replyText form").submit(function() {
    if (!($(this).find("#compose-body").val().replace(/\s+/, "") === "")) {
      submitPost(this);
    }
    return false;
  });
});
