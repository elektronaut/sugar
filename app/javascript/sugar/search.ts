import $ from "jquery";
import readyHandler from "../lib/readyHandler";

readyHandler.ready(() => {
  $("#search form").each(function () {
    $(this)
      .find("#search_mode")
      .change(function () {
        this.parentNode.action = this.value as string;
      });
    $(this).submit(() => {
      const query = encodeURIComponent($(this).find(".query").val());
      let action = this.action as string;
      if (!action.match(/^https?:\/\//)) {
        const baseDomain = document.location
          .toString()
          .match(/^(https?:\/\/[\w\d\-.]+)/)[1];
        action = baseDomain + action;
      }
      document.location = action + "?q=" + query;
      return false;
    });
  });
});
