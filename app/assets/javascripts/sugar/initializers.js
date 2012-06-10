$.extend(window.Sugar.Initializers, {

  layout : function () {
    // Adjust min-width of #content to always contain table.discussions
    $('table.discussions').each(function () {
      $('#content').css('min-width', $(this).outerWidth() + 'px');
    });
    // Adjust min-width of #wrapper to always contain content and sidebar if the sidebar exists
    $('#sidebar').each(function () {
      var minWidth = $('#content').outerWidth() + $('#sidebar').outerWidth();
      $('#wrapper').css('min-width', minWidth + 'px');
    });
    // Make entire category li clickable
    $('ul.categories li a').each(function () {
      var url = this.href;
      $(this).closest('li').click(function () {
        document.location = url;
      });
    });
  },

  loginForm : function () {
    $('body.login #login').each(function () {
      var container = this;

      if ($.cookie('login_method') === 'openid') {
        $(container).find('.username_and_password.form').hide();
      } else {
        $(container).find('.openid.form').hide();
      }

      $(container).find('.openid_toggle').click(function () {
        $(container).find('.username_and_password.form').hide();
        $(container).find('.openid.form').show();
        $.cookie('login_method', 'openid', {expires: 365});
      });

      $(container).find('.username_and_password_toggle').click(function () {
        $(container).find('.username_and_password.form').show();
        $(container).find('.openid.form').hide();
        $.cookie('login_method', null, {expires: 365});
      });
    });
  },

  profileEditing : function () {
    $('.edit_user_profile').each(function () {
      var checkTrusted = function () {
        if ($('#user_user_admin:checked').val() || $('#user_moderator:checked').val()) {
          $('#user_trusted').attr('checked', true);
          $('#user_trusted').attr('disabled', true);
        } else {
          $('#user_trusted').attr('disabled', false);
        }
      };
      var checkAdmin = function () {
        if ($('#user_admin:checked').val()) {
          $('#user_moderator').attr('checked', true);
          $('#user_user_admin').attr('checked', true);
          $('#user_moderator').attr('disabled', true);
          $('#user_user_admin').attr('disabled', true);
        } else {
          $('#user_moderator').attr('disabled', false);
          $('#user_user_admin').attr('disabled', false);
        }
      };
      $('#user_moderator, #user_user_admin').click(function () {
        checkTrusted();
      });
      $('#user_admin').click(function () {
        checkAdmin();
        checkTrusted();
      });
      checkAdmin();
      checkTrusted();
    });
  },

  searchMode: function () {
    $('#search form').each(function () {
      var form = this;
      // Observe the search mode selection box, set the proper action.
      $(form).find('#search_mode').change(function () {
        this.parentNode.action = this.value;
      });
      // Make better search URLs
      $(form).submit(function () {
        var action = form.action;
        if (!action.match(/^https?:\/\//)) {
          // Safari doesn't like document.location being set to a relative path
          var baseDomain = document.location.toString().match(/^(https?:\/\/[\w\d\-\.]+)/)[1];
          action = baseDomain + action;
        }
        var query = encodeURIComponent($(form).find('.query').val());
        var searchURL = action + "?q=" + query;
        document.location = searchURL;
        return false;
      });
    });
  },

  tabs: function () {
    jQuery('#reply-tabs').each(function () {
      window.replyTabs = new SugarTabs(this, {showFirstTab: false});
      if (jQuery('body.last_page').length > 0) {
        window.replyTabs.controls.showTab(window.replyTabs.tabs[0]);
      }
    });
    jQuery('#signup-tabs').each(function () {
      window.signupTabs = new SugarTabs(this, {showFirstTab: true});
    });
    jQuery('.admin.configuration .tabs').each(function () {
      window.configTabs = new SugarTabs(this, {showFirstTab: true});
    });

  },

  // Strip discussion and category names from links if workSafe is enabled.
  makeURLSWorkSafe : function () {
    var apply = function () {
      if (Sugar.Configuration.workSafe) {
        var stripExp  = /(\/[\d]+)(;[^\/]+)/;
        var domainExp = /^(https?:\/\/[^\/]+)/;
        var currentDomain = document.location.toString().match(domainExp)[1];
        var currentDomainExp = new RegExp("^" + currentDomain);
        $('a').each(function () {
          if (this.href.match(currentDomainExp) && this.href.match(stripExp)) {
            this.href = this.href.toString().replace(stripExp, "$1");
          }
        });
      }
    };
    $(Sugar).bind('postsloaded', apply);
    apply();
  },

  napkin: function () {
    if (jQuery('#napkin').length > 0) {
      // Setup callbacks
      window.uploadDrawing = function () {
        jQuery('#napkin-submit').text("Posting, please wait...");
        swfobject.getObjectById("napkin").uploadDrawing();
      };
      window.onDrawingUploaded = function (url) {
        window.location.reload();
      };

      // Make napkins clickable
      jQuery('.drawing img').each(function () {
        jQuery(this).click(function () {
          if (swfobject.getObjectById("napkin")) {
            swfobject.getObjectById("napkin").setBackground(this.src);
          }
        });
      });
    }
  },

  profileTweets: function () {
    $('#profileTweets').each(function () {
      var tweetsDiv = this;
      var username = $(this.parentNode).find('.username').get()[0].innerHTML.replace(/^@/, '');
      var user_info_url = "http://twitter.com/users/show/" + username + ".json?callback=?";
      var updates_url = "http://twitter.com/statuses/user_timeline/" + username + ".json?count=5&callback=?";
      $.getJSON(user_info_url, function (user_json) {
        var protectedMode = 'protected';
        if (user_json[protectedMode]) {
          $(tweetsDiv).html("<p>Updates are protected</p>");
        } else {
          $.getJSON(updates_url, function (json) {
            $(json).each(function () {
              var linkified_text = this.text.replace(/[A-Za-z]+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:%&\?\/.=]+/, function (m) {
                return m.link(m);
              });
              linkified_text = linkified_text.replace(/@[A-Za-z0-9_]+/, function (u) {
                return u.link('http://twitter.com/' + u.replace(/^@/, ''));
              });
              $(tweetsDiv).append('<div class="tweet tweet-' + this.id + '">' + '<p class="text">' + linkified_text + ' <a href="http://twitter.com/' + username + '/statuses/' + this.id + '" class="time">' + relativeTime(this.created_at) + '</a>' + '</p>' + '</div>');
            });
          });
        }
      });
    });
  },

  profileFlickr: function () {
    if (Sugar.Configuration.FlickrAPI) {
      $('#flickrProfileURL').each(function () {
        var fuid = this.href.split("/");
        fuid = fuid[(fuid.length - 1)];
        jQuery(function () {
          $('#flickrPhotos').hide();
          jQuery("#flickrPhotos").flickr({
            api_key:  Sugar.Configuration.FlickrAPI,
            type:     'search',
            user_id:  fuid,
            per_page: 15,
            callback: function (list) {
              $('#flickrPhotos').show();
            }
          });
        });
      });
    }
  },

  newPostsCount: function () {
    if ($('.total_items_count').length > 0 && $('#newPosts').length > 0 && $('body.last_page').length > 0) {
      Sugar.updateNewPostsCounter();
    }
  },

  newDiscussionSearcher: function () {
    $('#new_discussion').each(function () {
      var title = $(this).find('.title').get(0);
      $(title).after('<div class="title_search"></div>');
      var searchResults = $(this).find('.title_search').get(0);
      $(searchResults).hide();
      $(title).keydown(function (event) {
        setTimeout(function () {
          if ($(title).val() && title.previousValue !== $(title).val()) {
            title.previousValue = $(title).val();
            $(searchResults).addClass('loading').html('Searching for similar discussions...').show();
            if (title.keypressInterval) {
              clearInterval(title.keypressInterval);
            }
            title.keypressInterval = setInterval(function () {
              var words = $(title).val().toLowerCase().split(/\s+/);
              words = $.grep(words, function (word) {
                return ($.inArray(word, Sugar.stopwords) < 0);
              });
              // Ignore special characters
              words = $.map(words, function (word) {
                return word.replace(/[!~\^=\$\*\[\]\{\}]/, '');
              });
              if (words[words.length - 1].match(/^[\w]{3}[^\*]*$/)) {
                words[words.length - 1] += '*';
              }
              var query = words.join(' | ');
              // Load results
              $.getJSON('/discussions/search.json', {query: query}, function (json) {
                Sugar.log('New discussion: Loaded ' + json.discussions.length + ' of ' + json.total_entries + ' search results for "' + query + '"');
                $(searchResults).removeClass('loading');
                if (json.discussions.length > 0) {
                  var output = "<h4>Similar discussions found. Maybe you should check them out before posting?</h4>";
                  var discussion = null;
                  for (var a = 0; a < 10; a += 1) {
                    if (a < json.discussions.length) {
                      discussion = json.discussions[a].discussion;
                      output += '<a href="/discussions/' + discussion.id + '" class="discussion">' + discussion.title + ' <span class="posts_count">' + discussion.posts_count + ' posts</span></a>';
                    }
                  }
                  if (json.total_entries > 10) {
                    output += '<a href="/search?q=' + encodeURIComponent(query) + '">Show all ' + (json.total_entries) + ' results</a>';
                  }
                  $(searchResults).html(output).hide().slideDown('fast');
                } else {
                  $(searchResults).html('').hide();
                }
              });
              clearInterval(title.keypressInterval);
            }, 500);
          }
        }, 10);
      });
    });
  }

});