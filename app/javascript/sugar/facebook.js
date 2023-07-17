import Sugar from "../sugar";
import readyHandler from "../lib/readyHandler";

const Facebook = {
  appId: false,
  apiReady: false,

  init: function () {
    this.appId = Sugar.Configuration.facebookAppId;
    this.loadAsync();
    document.addEventListener("postsloaded", (event) => {
      Facebook.parsePosts(event.detail);
    });
  },

  withAPI: function (callback) {
    const facebook = this;
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

  loadAsync: function () {
    const facebook = this;

    window.fbAsyncInit = function () {
      window.FB.init({
        version: "v16.0",
        appId: Facebook.appId,
        status: true,
        cookie: true,
        xfbml: true
      });
      facebook.apiReady = true;
    };

    const fbRoot = document.createElement("div");
    fbRoot.id = "fb-root";
    document.body.appendChild(fbRoot);

    const script = document.createElement("script");
    script.id = "facebook-scriptsdk";
    script.src = "//connect.facebook.net/en_US/sdk.js";
    script.crossorigin = "anonymous";
    script.async = true;
    script.defer = true;
    document.body.append(script);
  },

  parsePosts: function (posts) {
    this.withAPI(function () {
      posts.forEach((post) => {
        window.FB.XFBML.parse(post);
      });
    });
  }
};

readyHandler.ready(() => {
  if (Sugar.Configuration.facebookAppId) {
    Facebook.init();
  }
});
