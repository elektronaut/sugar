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
      FB.init({
        version: 'v2.10',
        appId: Sugar.Facebook.appId,
        status: true,
        cookie: true,
        xfbml: true
      });
      facebook.apiReady = true;
    }

    $("body").append("<div id=\"fb-root\" />");
    let fjs = document.getElementsByTagName("script")[0];
    let js = document.createElement("script");
    js.id = "facebook-jssdk";
    js.src = "//connect.facebook.net/en_US/sdk.js";
    fjs.parentNode.insertBefore(js, fjs);
  },

  parsePosts: function (posts) {
    this.withAPI(function () {
      posts.each(function () {
        FB.XFBML.parse(this);
      });
    });
  }
};

$(Sugar).bind("ready", function() {
  if (this.Configuration.facebookAppId) {
    this.Facebook.init();
  }
});
