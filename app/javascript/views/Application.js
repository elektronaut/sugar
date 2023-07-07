import Backbone from "backbone";
import $ from "jquery";
import Posts from "./Posts";

export default Backbone.View.extend({
  el: $("body"),

  initialize: function () {
    const postsSelector =
      "body.discussion div.posts, " +
      "body.search div.posts, " +
      "body.user_profile div.posts";
    $(postsSelector).each(function () {
      this.view = new Posts({
        el: this
      });
    });
  }
});
