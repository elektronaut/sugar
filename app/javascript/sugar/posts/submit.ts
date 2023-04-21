import $ from "jquery";
import Sugar from "../../sugar";

$(Sugar).bind("ready", function () {
  // Submit post via AJAX
  function submitPost(form: HTMLFormElement) {
    $(Sugar).trigger("posting-status", ["Posting, please wait&hellip;"]);

    if ($(form).hasClass("livePost")) {
      const body = $("#compose-body").val();
      const format = $("#compose-body").closest("form").find(".format").val();

      void $.ajax({
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
          if ("loadNewPosts" in Sugar) {
            Sugar.loadNewPosts();
          }
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
  }

  // Form event handler
  $("#replyText form").submit(function(_, form: HTMLFormElement) {
    const composeBody = $(form).find("#compose-body").val() as string;
    if (!(composeBody.replace(/\s+/, "") === "")) {
      submitPost(form);
    }
    return false;
  });
});
