Sugar.PostDetector = {
  paused: false,
  model: null,
  interval: null,
  total_posts: null,
  read_posts: null,

  refresh: function() {
    if (!this.paused) {
      let detector = this;
      $.getJSON(this.model.postsCountUrl({timestamp: true}), function(json) {
        var new_posts = json.posts_count - detector.total_posts;
        if (new_posts > 0) {
          detector.total_posts = json.posts_count;
          return $(Sugar).trigger(
            'newposts',
            [
              detector.total_posts,
              new_posts,
              (detector.total_posts - detector.read_posts)
            ]
          );
        }
      });
    }
  },

  start: function(container) {
    this.paused = false;

    var modelClass = Sugar.Models.Discussion;
    if ($(container).data("type") === "Conversation") {
      var modelClass = Sugar.Models.Conversation;
    }

    this.model = new modelClass({
      id: $(container).data('id'),
      posts_count: $(container).data('posts-count')
    });

    if (!this.read_posts) {
      this.read_posts = this.model.get('posts_count');
    }

    if (!this.total_posts) {
      this.total_posts = this.read_posts;
    }

    if (!this.interval) {
      this.interval = setInterval((function() {
        Sugar.PostDetector.refresh();
      }), 5000);
    }
  },

  stop: function() {
    this.paused = true;
    clearInterval(this.interval);
    this.interval = null;
  },

  pause: function() {
    this.paused = true;
  },

  resume: function() {
    this.paused = false;
  },

  mark_posts_read: function(count) {
    this.read_posts += count;
    if (this.total_posts < this.read_posts) {
      this.total_posts = this.read_posts;
    }
  }
}

Sugar.loadNewPosts = function() {
  if ($("#discussionLink").length > 0) {
    Sugar.PostDetector.pause();
    $(Sugar).trigger('postsloading');

    var exchangeUrl = $("#discussionLink").get()[0].href;
    var exchangeType = exchangeUrl.match(
      /\/\/[\w\d\.:]+\/(discussions|conversations)\/([\d]+)/
    )[1];
    var exchangeId = exchangeUrl.match(
      /\/\/[\w\d\.:]+\/(discussions|conversations)\/([\d]+)/
    )[2];

    var endpoint = `/${exchangeType}/${exchangeId}/posts` +
                   `/since/${Sugar.PostDetector.read_posts}`;

    return $.get(endpoint, function(data) {
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
      Sugar.PostDetector.mark_posts_read(new_posts.length);

      Sugar.PostDetector.resume();
      $(Sugar).trigger('postsloaded', [new_posts]);
    });
  }
};


$(Sugar).bind('ready', function() {
  // Start the post detector
  if ($('#discussion').length > 0 &&
      $('#newPosts').length > 0 &&
      $('body.last_page').length > 0) {
    Sugar.PostDetector.start($('#discussion').get(0));
  }

  // -- Window title --

  var originalTitle = document.title;

  // Update the window title on new posts
  $(Sugar).bind('newposts', function(event, total, newPosts, unread) {
      document.title = `(${unread}) ${originalTitle}`;
    }
  );

  // Reset the document title when posts are loaded
  $(Sugar).bind('postsloaded', function() {
    document.title = originalTitle;
  });

  // -- Paginator --

  // Update the total posts count on the paginator
  $(Sugar).bind('newposts', function(event, total) {
    $('.total_items_count').text(total);
  });

  // Update the number of shown posts
  $(Sugar).bind('postsloaded', function() {
    $('.shown_items_count').text(Sugar.PostDetector.read_posts);
  });

  // -- Notification --

  // Show the notification on new posts
  $(Sugar).bind('newposts', function(event, total, newPosts, unread) {
    var notification_string = "A new post has been made";
    if (unread > 1) {
      notification_string = `${unread} new posts have been made`;
    }

    notification_string += ', <a href="' + $('#discussionLink').get()[0].href +
                           '">click here to load</a>.';
    $('#newPosts').html(`<p>${notification_string}</p>`);
    $('#newPosts a').click(function() {
      Sugar.loadNewPosts();
      return false;
    });

    // Slide the notification in
    if (!$('#newPosts').hasClass('new_posts_since_refresh')) {
      $('#newPosts').addClass('new_posts_since_refresh').hide().slideDown();
    }
  });

  // Show loading status
  $(Sugar).bind('postsloading', function() {
    $('#newPosts').addClass('new_posts_since_refresh').html('Loading&hellip;');
  });

  // Hide when posts are loaded
  $(Sugar).bind('postsloaded', function() {
    $('#newPosts').removeClass('new_posts_since_refresh').html('').hide();
  });
});
