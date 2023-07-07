import $ from "jquery";
import Sugar from "../../sugar";
import readyHandler from "../../lib/readyHandler";

readyHandler.ready(() => {
  const $buttons = $("#button-container");

  function showStatus(message: string) {
    $buttons.find(".status").html(message);
    $buttons.find("button").hide();
    return $buttons.addClass("posting");
  }

  function clearStatus() {
    $buttons.find(".status").html("");
    $buttons.find("button").fadeIn("fast");
    $buttons.removeClass("posting");
    if ($(".posts #previewPost").length > 0) {
      $buttons.find(".preview span").html("Update Preview");
    } else {
      $buttons.find(".preview span").html("Preview");
    }
  }

  $(Sugar).bind("posting-status", function (_, message: string) {
    showStatus(message);
  });

  $(Sugar).bind("posting-complete", function () {
    clearStatus();
  });
});
