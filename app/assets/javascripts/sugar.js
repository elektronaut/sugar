/*jslint browser: true, devel: true, onevar: false, regexp: false*/
/*global window: false, jQuery: false, $: false, JRichTextArea: false, SugarTabs: false, swfobject: false, relativeTime: false*/

var Sugar = {
	Configuration: {},
	onLoadedPosts: {
		syntaxHighlight: function () {
			Sugar.Initializers.syntaxHighlight();
		},
	},
	Initializers: {},

	updateNewPostsCounter : function () {
		var newPosts = $('#newPosts').get()[0];
		newPosts.postsCount = parseInt($('.total_items_count').eq(0).text(), 10);
		if (!newPosts.originalCount) {
			newPosts.originalCount = newPosts.postsCount;
		}
		newPosts.postsCountUrl = $('#discussionLink').get()[0].href.match(/^(https?:\/\/[\w\d\.:]+\/discussions\/[\d]+)/)[1] + "/posts/count.js";
		newPosts.documentTitle = document.title;

		newPosts.refreshInterval = setInterval(function () {
			if (!Sugar.loadingPosts) {
				$.getJSON(newPosts.postsCountUrl, function (json) {
					if (json.posts_count > newPosts.postsCount && !Sugar.loadingPosts) {
						var newPostsSinceRefresh = json.posts_count - newPosts.postsCount;
						$('.total_items_count').text(json.posts_count);
						var newPostsString = "A new post has";
						if (newPostsSinceRefresh === 1) {
							document.title = "[" + newPostsSinceRefresh + " new post] " + newPosts.documentTitle;
						} else {
							newPostsString = newPostsSinceRefresh + " new posts have";
							document.title = "[" + newPostsSinceRefresh + " new posts] " + newPosts.documentTitle;
						}
						if ($('body.last_page').length > 0) {
							$(newPosts).html('<p>' + newPostsString + ' been made since this page was loaded, <a href="' + $('#discussionLink').get()[0].href + '" onclick="Sugar.loadNewPosts(); return false;">click here to load</a>.</p>');
						} else {
							$(newPosts).html('<p>' + newPostsString + ' been made since this page was loaded, move on to the last page to see them.</p>');
						}
						newPosts.serverPostsCount = json.posts_count;
						if (!newPosts.shown) {
							$(newPosts).addClass('new_posts_since_refresh').hide().slideDown();
							newPosts.shown = true;
						}
					}
				});
			}
		}, 5000);
	},

	stopwords: [
		'i', 'a', 'about', 'an', 'and', 'are', 'as', 'at', 'by', 'for', 'from', 'has', 'have',
		'how', 'in', 'is', 'it', 'la', 'my', 'of', 'on', 'or', 'that', 'the',
		'this', 'to', 'was', 'what', 'when', 'where', 'who', 'will', 'with', 'the'
	],

	/*
		Get authenticity token from a form
	*/
	authToken : function (elem) {
		var authToken = null;
		if (elem) {
			authToken = $(elem).find("input[name='authenticity_token']").val();
		} else {
			authToken = $("input[name='authenticity_token']").val();
		}
		return authToken;
	},

	loadNewPosts : function () {
		if ($('#discussionLink').length > 0) {
			var newPosts    = $('#newPosts').get()[0];
			var newPostsURL = $('#discussionLink').get()[0].href.match(/^(https?:\/\/[\w\d\.:]+\/discussions\/[\d]+)/)[1] + "/posts/since/" + newPosts.postsCount;

			Sugar.loadingPosts = true;
			$(newPosts).html('Loading&hellip;');
			$(newPosts).addClass('new_posts_since_refresh');

			$.get(newPostsURL, function (data) {
				$(newPosts).hide();

				if ($('.posts #ajaxPosts').length < 1) {
					$('.posts').append('<div id="ajaxPosts"></div>');
				}

				$('.posts #ajaxPosts').append(data);
				$('.posts #ajaxPosts .post:not(.shown)').hide().slideDown().addClass('shown');

				// Reset the notifier
				document.title = newPosts.documentTitle;
				newPosts.serverPostsCount = newPosts.originalCount + $('.posts #ajaxPosts').children('.post').size();
				newPosts.postsCount = newPosts.serverPostsCount;
				newPosts.shown = false;

				$('.shown_items_count').text(newPosts.postsCount);
				$('.total_items_count').text(newPosts.postsCount);

				Sugar.Initializers.postFunctions();
				Sugar.loadingPosts = false;

				for (var f in Sugar.onLoadedPosts) {
					if (Sugar.onLoadedPosts.hasOwnProperty(f)) {
						Sugar.onLoadedPosts[f]();
					}
				}
				$(Sugar).trigger('postsloaded');
			});
		}
		return false;
	},
	
	log: function () {
		if (this.Configuration.debug) {
			if (console) {
				if (arguments.length === 1) {
					console.log(arguments[0]);
				} else if (arguments.length > 1) {
					var output = [];
					$(arguments).each(function () {
						output[output.length] = this;
					});
					console.log(output);
				}
			}
		}
	},

	init : function () {
		for (var initializer in this.Initializers) {
			if (this.Initializers.hasOwnProperty(initializer)) {
				this.Initializers[initializer]();
			}
		}
		$(this).trigger('ready');
	}
};