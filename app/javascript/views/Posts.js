import Backbone from "backbone";
import $ from "jquery";

import Sugar from "../sugar";
import Post from "./Post";

export default Backbone.View.extend({
  el: $("div.posts"),

  initialize: function () {
    $(Sugar).bind("postsloaded", function (event, posts) {
      posts.each(function () {
        new Post({ el: this }).render();
      });
    });
    $(Sugar).trigger("postsloaded", [$(this.el).find(".post")]);
  }
});
