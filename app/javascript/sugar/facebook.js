import $ from "jquery";
import Sugar from "../sugar";

Sugar.Facebook = {
  appId: false,
  apiReady: false,

  init: function() {
    this.appId = Sugar.Configuration.facebookAppId;
    if ($(".fb_button").length > 0) {
      $(".fb_button").addClass("fb_button_large")
                     .wrapInner("<span class=\"fb_button_text\" />");
    }
    this.loadAsync();
    $(Sugar).bind("postsloaded", function(event, posts) {
      Sugar.Facebook.parsePosts(posts);
    });
  },

  withAPI: function(callback) {
    let facebook = this;
    if (this.apiReady) {
      callback();
    } else {
      var interval = setInterval(function () {
        if (facebook.apiReady) {
          clearInterval(interval);
          callback();
        }
      }, 50);
    }
  },

  loadAsync: function() {
    let facebook = this;

    window.fbAsyncInit = function () {
      window.FB.init({
        version: "v16.0",
        appId: Sugar.Facebook.appId,
        status: true,
        cookie: true,
        xfbml: true
      });
      facebook.apiReady = true;
    };

    $("body").append("<div id=\"fb-root\" />");

    let script = document.createElement("script");
    script.id = "facebook-scriptsdk";
    script.src = "//connect.facebook.net/en_US/sdk.js";
    script.crossorigin = "anonymous";
    script.async = true;
    script.defer = true;
    document.body.append(script);
  },

  parsePosts: function (posts) {
    this.withAPI(function () {
      posts.each(function () {
        window.FB.XFBML.parse(this);
      });
    });
  }
};

$(Sugar).bind("ready", function() {
  if (this.Configuration.facebookAppId) {
    this.Facebook.init();
  }
});
