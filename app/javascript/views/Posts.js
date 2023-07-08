import Backbone from "backbone";
import $ from "jquery";

import Post from "./Post";

export default Backbone.View.extend({
  el: $("div.posts"),

  initialize: function () {
    document.addEventListener("postsloaded", (event) => {
      $(event.detail).each(function () {
        new Post({ el: this }).render();
      });
    });
    document.dispatchEvent(
      new CustomEvent("postsloaded", {
        detail: $(this.el).find(".post")
      })
    );
  }
});
