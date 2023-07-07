import $ from "jquery";
import readyHandler from "../lib/readyHandler";
import Sugar from "../sugar";

import "timeago";

function formatDate(date) {
  let months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  return (
    months[date.getMonth()] + " " + date.getDate() + ", " + date.getFullYear()
  );
}

function applyTimestamps() {
  const tags = document.querySelectorAll("time.relative");
  tags.forEach((elem) => {
    if (elem.getAttribute("datetime")) {
      let date = $.timeago.parse(elem.getAttribute("datetime"));
      let delta = (new Date().getTime() - date.getTime()) / 1000;
      if (delta < 14 * 24 * 24 * 60) {
        $(elem).timeago();
      } else {
        elem.innerHTML = formatDate(date);
      }
    }
  });
}

applyTimestamps();
readyHandler.ready(applyTimestamps);
$(Sugar).bind("postsloaded", applyTimestamps);
