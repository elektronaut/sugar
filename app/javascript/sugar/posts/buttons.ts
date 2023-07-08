import $ from "jquery";
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

  document.addEventListener("posting-status", (event: PostingStatusEvent) => {
    showStatus(event.detail);
  });

  document.addEventListener("posting-complete", () => {
    clearStatus();
  });
});
