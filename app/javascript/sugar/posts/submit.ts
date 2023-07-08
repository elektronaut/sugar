import $ from "jquery";
import Sugar from "../../sugar";
import readyHandler from "../../lib/readyHandler";

readyHandler.ready(() => {
  // Submit post via AJAX
  function submitPost(form: HTMLFormElement) {
    document.dispatchEvent(
      new CustomEvent("posting-status", {
        detail: "Posting, please wait&hellip;"
      })
    );

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
          document.dispatchEvent(new Event("posting-complete"));
        }
      });
    } else {
      form.submit();
    }
  }

  // Form event handler
  $("#replyText form").submit(function () {
    const composeBody = $(this).find("#compose-body").val() as string;
    if (!(composeBody.replace(/\s+/, "") === "")) {
      submitPost(this);
    }
    return false;
  });
});
