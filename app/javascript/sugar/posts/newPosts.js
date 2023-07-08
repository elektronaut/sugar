import $ from "jquery";
import Sugar from "../../sugar";
import readyHandler from "../../lib/readyHandler";

const PostDetector = {
  id: null,
  paused: false,
  interval: null,
  total_posts: null,
  read_posts: null,
  type: "Discussion",

  refresh: function () {
    if (!this.paused) {
      let detector = this;
      $.getJSON(this.postsCountUrl(), function (json) {
        var new_posts = json.posts_count - detector.total_posts;
        if (new_posts > 0) {
          detector.total_posts = json.posts_count;
          document.dispatchEvent(
            new CustomEvent("newposts", {
              detail: {
                total: detector.total_posts,
                newPosts: new_posts,
                unread: detector.total_posts - detector.read_posts
              }
            })
          );
        }
      });
    }
  },

  postsCountUrl: function () {
    const baseUrl =
      this.type === "Conversation" ? "/conversations" : "/discussions";
    return `${baseUrl}/${this.id}/posts/count.json?` + new Date().getTime();
  },

  start: function (container) {
    this.paused = false;

    if ($(container).data("type") === "Conversation") {
      this.type = "Conversation";
    }

    this.id = $(container).data("id");

    if (!this.read_posts) {
      this.read_posts = $(container).data("posts-count");
    }

    if (!this.total_posts) {
      this.total_posts = this.read_posts;
    }

    if (!this.interval) {
      this.interval = setInterval(function () {
        PostDetector.refresh();
      }, 5000);
    }
  },

  stop: function () {
    this.paused = true;
    clearInterval(this.interval);
    this.interval = null;
  },

  pause: function () {
    this.paused = true;
  },

  resume: function () {
    this.paused = false;
  },

  mark_posts_read: function (count) {
    this.read_posts += count;
    if (this.total_posts < this.read_posts) {
      this.total_posts = this.read_posts;
    }
  }
};

Sugar.loadNewPosts = function () {
  if ($("#discussionLink").length > 0) {
    PostDetector.pause();
    document.dispatchEvent(new Event("postsloading"));

    var exchangeUrl = $("#discussionLink").get()[0].href;
    var exchangeType = exchangeUrl.match(
      /\/\/[\w\d.:]+\/(discussions|conversations)\/([\d]+)/
    )[1];
    var exchangeId = exchangeUrl.match(
      /\/\/[\w\d.:]+\/(discussions|conversations)\/([\d]+)/
    )[2];

    var endpoint =
      `/${exchangeType}/${exchangeId}/posts` +
      `/since/${PostDetector.read_posts}`;

    return $.get(endpoint, function (data) {
      // Create the container if necessary
      if ($(".posts #ajaxPosts").length < 1) {
        $(".posts").append('<div id="ajaxPosts"></div>');
      }

      // Insert the content
      $(".posts #ajaxPosts").append(data);
      var new_posts = $(".posts #ajaxPosts .post:not(.shown)");

      // Animate in the new posts
      new_posts.hide().slideDown().addClass("shown");

      // Update read posts count
      PostDetector.mark_posts_read(new_posts.length);

      PostDetector.resume();
      document.dispatchEvent(
        new CustomEvent("postsloaded", {
          detail: new_posts.get()
        })
      );
    });
  }
};

readyHandler.ready(() => {
  // Start the post detector
  if (
    $("#discussion").length > 0 &&
    $("#newPosts").length > 0 &&
    $("body.last_page").length > 0
  ) {
    PostDetector.start($("#discussion").get(0));
  }

  // -- Window title --

  var originalTitle = document.title;

  // Update the window title on new posts
  document.addEventListener("newposts", (event) => {
    document.title = `(${event.detail.unread}) ${originalTitle}`;
  });

  // Reset the document title when posts are loaded
  document.addEventListener("postsloaded", () => {
    document.title = originalTitle;
  });

  // -- Paginator --

  // Update the total posts count on the paginator
  document.addEventListener("newposts", (event) => {
    $(".total_items_count").text(event.detail.total);
  });

  // Update the number of shown posts
  document.addEventListener("postsloaded", () => {
    $(".shown_items_count").text(PostDetector.read_posts);
  });

  // -- Notification --

  // Show the notification on new posts
  document.addEventListener("newposts", (event) => {
    var notification_string = "A new post has been made";
    if (event.detail.unread > 1) {
      notification_string = `${event.detail.unread} new posts have been made`;
    }

    notification_string +=
      ', <a href="' +
      $("#discussionLink").get()[0].href +
      '">click here to load</a>.';
    $("#newPosts").html(`<p>${notification_string}</p>`);
    $("#newPosts a").click(function () {
      Sugar.loadNewPosts();
      return false;
    });

    // Slide the notification in
    if (!$("#newPosts").hasClass("new_posts_since_refresh")) {
      $("#newPosts").addClass("new_posts_since_refresh").hide().slideDown();
    }
  });

  // Show loading status
  document.addEventListener("postsloading", () => {
    $("#newPosts").addClass("new_posts_since_refresh").html("Loading&hellip;");
  });

  // Hide when posts are loaded
  document.addEventListener("postsloaded", () => {
    $("#newPosts").removeClass("new_posts_since_refresh").html("").hide();
  });
});
