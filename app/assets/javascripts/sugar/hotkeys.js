/*
 * Sugar.Hotkeys - Contextual aware keyboard navigation hotkeys.
 * Copyright (c) 2009 Inge Jørgensen (elektronaut.no)
 */

/*jslint browser: true, devel: true, onevar: false, regexp: false, immed: false*/
/*global window: false, jQuery: false, $: false, Sugar: false*/

(function ($S) {

  $($S).bind('ready', function () {
    this.Hotkeys.apply();
  });

  $S.Hotkeys = {
    defaultTarget: false,
    targets:       [],
    currentTarget: false,
    keySequence:   '',
    specialKeys: { 27: 'esc', 9: 'tab', 32: 'space', 13: 'return', 8: 'backspace', 145: 'scroll',
      20: 'capslock', 144: 'numlock', 19: 'pause', 45: 'insert', 36: 'home', 46: 'del',
      35: 'end', 33: 'pageup', 34: 'pagedown', 37: 'left', 38: 'up', 39: 'right', 40: 'down',
      112: 'f1', 113: 'f2', 114: 'f3', 115: 'f4', 116: 'f5', 117: 'f6', 118: 'f7', 119: 'f8',
      120: 'f9', 121: 'f10', 122: 'f11', 123: 'f12', 191: '/',
      96: '0', 97: '1', 98: '2', 99: '3', 100: '4', 101: '5', 102: '6', 103: '7', 104: '8', 105: '9', 106: '*',
      107: '+', 109: '-', 110: '.', 111: '/'
    },

    // Apply functionality
    apply: function () {
      if ($('table.discussions').length > 0) {
        this.setup.discussionsNavigation();
        this.setup.discussionsFunctions();
      }
      if ($('.posts .post').length > 0) {
        this.setup.postsNavigation();
        this.setup.postsFunctions();
      }
      this.setup.global();
      this.setup.sequences();
      $S.log('Hotkeys: Loaded, ' + this.targets.length + ' targets detected.');
    },

    // Add target to list
    addTarget: function (target, targetId) {
      if ($.inArray(target, this.targets) < 0) {
        $(target).data('targetId', targetId);
        this.targets[this.targets.length] = target;
      }
    },

    // Get current target
    getTarget: function () {
      return ((this.currentTarget) ? this.currentTarget : false);
    },

    // Scroll to target
    scrollTo: function (target) {
      var targetPosition = $(target).offset().top;
      var bottom = $(window).height() + $(window).scrollTop();

      if (targetPosition > bottom || targetPosition < $(window).scrollTop() || (targetPosition + $(target).height()) > bottom) {
        $.scrollTo(target, {duration: 100, offset: { top: -50, left: 0 }, axis: 'y'});
      }
    },

    // Go to specific target
    gotoTarget: function (target) {
      this.currentTarget = target;
      $(this).trigger('targetchanged', [target]);
    },

    // Go to next target
    gotoNextTarget: function () {
      if (!this.currentTarget) {
        if (this.defaultTarget) {
          this.gotoTarget(this.defaultTarget);
        } else {
          this.gotoTarget(this.targets[0]);
        }
      } else {
        var index = $.inArray(this.currentTarget, this.targets) + 1;
        if (index >= this.targets.length) {
          index = 0;
        }
        this.gotoTarget(this.targets[index]);
      }
    },

    // Go to previous target
    gotoPrevTarget: function () {
      if (!this.currentTarget) {
        if (this.defaultTarget) {
          this.gotoTarget(this.defaultTarget);
          this.gotoPrevTarget();
        } else {
          this.gotoTarget(this.targets[this.targets.length - 1]);
        }
      } else {
        var index = $.inArray(this.currentTarget, this.targets) - 1;
        if (index < 0) {
          index = this.targets.length - 1;
        }
        this.gotoTarget(this.targets[index]);
      }
    },

    setup: {

      // Global hotkeys
      global: function () {
        var gotoPrevPage = function (event) {
          if (!event.metaKey && $('.prev_page_link').length > 0) {
            document.location = $('.prev_page_link').get(0).href;
          }
        };
        var gotoNextPage = function (event) {
          if (!event.metaKey && $('.next_page_link').length > 0) {
            document.location = $('.next_page_link').get(0).href;
          }
        };
        $(document).bind('keydown', 'shift+p', gotoPrevPage);
        $(document).bind('keydown', 'shift+k', gotoPrevPage);
        $(document).bind('keydown', 'shift+n', gotoNextPage);
        $(document).bind('keydown', 'shift+j', gotoNextPage);
        $(document).bind('keydown', 'u', function (event) {
          if (!event.metaKey && $('#back_link').length > 0) {
            document.location = $('#back_link').get(0).href;
            return false;
          }
        });
      },

      // Listen for sequences
      sequences: function () {
        $(document).bind('keydown', function (event) {
          var target = $(event.target);
          var character = !$S.Hotkeys.specialKeys[event.which] && String.fromCharCode(event.keyCode).toLowerCase();
          if (event.shiftKey && event.which >= 65 && event.which <= 90) {
            character = character.toUpperCase();
          }
          if (target.is("input") || target.is("textarea") || target.is("select")) {
            $S.Hotkeys.keySequence = '';
          } else {
            if (!event.metaKey && character && character.match(/^[\w\d]$/)) {
              $S.Hotkeys.keySequence += character;
              var keySequence = $S.Hotkeys.keySequence = $S.Hotkeys.keySequence.match(/([\w\d]{0,5})$/)[1]; // Limit to 5 keys
              var shortcuts = {
                '#discussions_link':   /gd$/,
                '#following_link':     /gf$/,
                '#favorites_link':     /gF$/,
                '#conversations_link': /gc$/,
                '#messages_link':      /gm$/,
                '#invites_link':       /gi$/,
                '#users_link':         /gu$/
              };
              for (var selector in shortcuts) {
                if (keySequence.match(shortcuts[selector]) && $(selector).length > 0) {
                  document.location = $(selector).get(0).href;
                }
              }
            }
          }
        });
      },

      // Navigating posts
      postsNavigation: function () {
        // Find targets
        $('.posts .post').each(function () {
          $S.Hotkeys.addTarget(this, this.id.match(/(post|message)\-([\d]+)/)[2]);
        });

        // Add targets on postsloaded
        $($S).bind('postsloaded', function () {
          $('.posts .post').each(function () {
            $S.Hotkeys.addTarget(this, this.id.match(/(post|message)\-([\d]+)/)[1]);
          });
        });

        // Set default target
        if (document.location.toString().match(/#(post|message)-([\d]+)/)) {
          $S.Hotkeys.defaultTarget = $('#post-' + document.location.toString().match(/#(post|message)-([\d]+)/)[2]).get(0);
        } else {
          $S.Hotkeys.defaultTarget = $('.posts > .post').get(0);
        }

        // Target changed event
        $($S.Hotkeys).bind('targetchanged', function (e, target) {
          $('.posts .post').removeClass('targeted');
          $(target).addClass('targeted');
          this.scrollTo(target);
        });

        // Keyboard bindings
        $(document).bind('keydown', 'p', function (event) {
          if (!event.metaKey) {
            $S.Hotkeys.gotoPrevTarget();
          }
        });
        $(document).bind('keydown', 'k', function (event) {
          if (!event.metaKey) {
            $S.Hotkeys.gotoPrevTarget();
          }
        });
        $(document).bind('keydown', 'n', function (event) {
          if (!event.metaKey) {
            $S.Hotkeys.gotoNextTarget();
          }
        });
        $(document).bind('keydown', 'j', function (event) {
          if (!event.metaKey) {
            $S.Hotkeys.gotoNextTarget();
          }
        });
      },

      // Posts functions
      postsFunctions: function () {
        // Load new posts
        $(document).bind('keydown', 'r', function (event) {
          if (!event.metaKey) {
            $S.loadNewPosts();
          }
        });

        // Go to compose
        $(document).bind('keydown', 'c', function (event) {
          if (!event.metaKey) {
            $S.compose();
            return false;
          }
        });

        // Quote post
        $(document).bind('keydown', 'q', function (event) {
          if (!event.metaKey && $S.Hotkeys.getTarget()) {
            $S.quotePost($S.Hotkeys.getTarget());
            return false;
          }
        });
      },

      // Navigating discussions
      discussionsNavigation: function () {
        // Find targets
        $('table.discussions td.name a').each(function () {
          $S.Hotkeys.addTarget(this, this.parentNode.parentNode.parentNode.className.match(/(discussion|conversation)([\d]+)/)[2]);
        });

        // Target change event
        $($S.Hotkeys).bind('targetchanged', function (e, target) {
          $('tr.discussion').removeClass('targeted');
          $('tr.discussion' + $(target).data('targetId')).addClass('targeted');
          $('tr.conversation').removeClass('targeted');
          $('tr.conversation' + $(target).data('targetId')).addClass('targeted');
          this.scrollTo(target);
        });

        // Key handlers
        $(document).bind('keydown', 'p', function (event) {
          if (!event.metaKey) {
            $S.Hotkeys.gotoPrevTarget();
          }
        });
        $(document).bind('keydown', 'k', function (event) {
          if (!event.metaKey) {
            $S.Hotkeys.gotoPrevTarget();
          }
        });
        $(document).bind('keydown', 'n', function (event) {
          if (!event.metaKey) {
            $S.Hotkeys.gotoNextTarget();
          }
        });
        $(document).bind('keydown', 'j', function (event) {
          if (!event.metaKey) {
            $S.Hotkeys.gotoNextTarget();
          }
        });
      },

      // Discussions functions
      discussionsFunctions: function () {
        // Opening target
        var openTarget = function (openInNewTab) {
          if ($S.Hotkeys.currentTarget) {
            var targetUrl = $S.Hotkeys.currentTarget.href;
            if (openInNewTab) {
              window.open(targetUrl);
            } else {
              document.location = targetUrl;
            }
          }
        };
        $(document).bind('keydown', 'o', function (event) {
          if (!event.metaKey) {
            openTarget(false);
          }
        });
        $(document).bind('keydown', 'shift+o', function (event) {
          if (!event.metaKey) {
            openTarget(true);
          }
        });
        $(document).bind('keydown', 'Return', function (event) {
          if (!event.metaKey) {
            openTarget(false);
          }
        });
        $(document).bind('keydown', 'shift+Return', function (event) {
          if (!event.metaKey) {
            openTarget(true);
          }
        });

        // Marking a read
        var markAsRead = function (event) {
          if (!event.metaKey && $S.Hotkeys.currentTarget && $($S.Hotkeys.currentTarget.parentNode.parentNode).hasClass('discussion')) {
            var target = $S.Hotkeys.currentTarget;
            var targetId = $(target).data('targetId');
            var url = '/discussions/' + targetId + '/mark_as_read';
            $.get(url, {}, function () {
              $('.discussion' + targetId).removeClass('new_posts');
              $('.discussion' + targetId + ' .new_posts').html('');
            });
          }
        };
        $(document).bind('keydown', 'y', markAsRead);
        $(document).bind('keydown', 'm', markAsRead);

        // New discussion/category
        $(document).bind('keydown', 'c', function (event) {
          if (!event.metaKey && $('.functions .create').length > 0) {
            document.location = $('.functions .create').get(0).href;
          }
        });
      }
    }
  };
})(window.Sugar);