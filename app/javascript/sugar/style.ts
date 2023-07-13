import $ from "jquery";
import readyHandler from "../lib/readyHandler";
import { setupTabs } from "./tabs";

function wrapButtons() {
  $("a.button, button").each(function () {
    if ($(this).find("span").length === 0) {
      $(this).wrapInner("<span />");
    }
  });
}

readyHandler.ready(() => {
  wrapButtons();
  const observer = new MutationObserver(() => {
    wrapButtons();
  });
  observer.observe(document.body, {
    attributes: true,
    childList: true,
    subtree: true
  });

  $("table.discussions").each(function () {
    $("#content").css("min-width", `${$(this).outerWidth()}px`);
  });

  $("#sidebar").each(function () {
    const minWidth = $("#content").outerWidth() + $("#sidebar").outerWidth();
    $("#wrapper").css("min-width", `${minWidth}px`);
  });

  $("#reply-tabs").each(function () {
    const [tabs, showTab] = setupTabs(this, { showFirstTab: false });

    if ($("body.last_page").length > 0) {
      showTab(tabs[0]);
    }

    $("#replyText textarea").on("focus", function () {
      showTab(tabs[0]);
    });

    document.addEventListener("quote", () => {
      showTab(tabs[0]);
    });
  });

  $("#signup-tabs").each(function () {
    setupTabs(this, { showFirstTab: true });
  });

  $(".admin.configuration .tabs").each(function () {
    setupTabs(this, { showFirstTab: true });
  });
});
