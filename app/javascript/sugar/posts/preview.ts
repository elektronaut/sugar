import $ from "jquery";
import Sugar from "../../sugar";
import readyHandler from "../../lib/readyHandler";

readyHandler.ready(() => {
  function previewPost() {
    const postBody = $("#compose-body").val();
    const format = $("#compose-body").closest("form").find(".format").val();
    const previewUrl = $("#compose-body")
      .closest("form")
      .data("preview-url") as string;

    document.dispatchEvent(
      new CustomEvent("posting-status", {
        detail: "Loading preview&hellip;"
      })
    );

    $(".posts #previewPost").animate({ opacity: 0.1 }, "fast");
    void $.ajax({
      url: previewUrl,
      type: "POST",
      data: {
        "post[body]": postBody,
        "post[format]": format,
        authenticity_token: Sugar.authToken()
      },

      success: function (previewPost: string) {
        // Inject the #ajaxPosts container so new posts
        // will be loaded above the prewview
        if ($(".posts #ajaxPosts").length < 1) {
          $(".posts").append('<div id="ajaxPosts"></div>');
        }

        // Create the container
        if ($(".posts #previewPost").length < 1) {
          $(".posts").append('<div id="previewPost"></div>');
        }

        $(".posts #previewPost").html(previewPost);

        // Animation
        if ($(".posts #previewPost").hasClass("shown")) {
          $(".posts #previewPost").animate({ opacity: 1.0 }, "fast");
        } else {
          $(".posts #previewPost").addClass("shown").hide().fadeIn();
        }

        document.dispatchEvent(
          new CustomEvent("postsloaded", {
            detail: $(".posts #previewPost").find(".post").get()
          })
        );
      },

      error: function (xhr) {
        alert("Error: " + xhr.responseText);
      },

      complete: function () {
        document.dispatchEvent(new Event("posting-complete"));
      }
    });
  }

  $("#replyText .preview").click(function () {
    previewPost();
  });
});
