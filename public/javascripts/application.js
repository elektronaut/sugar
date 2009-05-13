/**
 * @depends jquery.libraries.js
 */

window.relativeTime = function(timeString) {
	var parsedDate = Date.parse(timeString);
	var delta = (Date.parse(Date()) - parsedDate) / 1000;
	var r = '';
	if (delta < 60) {
		r = 'a moment ago';
	} else if(delta < 120) {
		r = 'a couple of minutes ago';
	} else if(delta < (45*60)) {
		r = (parseInt(delta / 60, 10)).toString() + ' minutes ago';
	} else if(delta < (90*60)) {
		r = 'an hour ago';
	} else if(delta < (24*60*60)) {
		r = '' + (parseInt(delta / 3600, 10)).toString() + ' hours ago';
	} else if(delta < (48*60*60)) {
		r = 'a day ago';
	} else {
		r = (parseInt(delta / 86400, 10)).toString() + ' days ago';
	}
	return r;
};

/* Dead simple tabs */
function SugarTabs(controls, options) {
	controls.tabs = [];
	
	settings = jQuery.extend({
		showFirstTab: true
	}, options);

	controls.hideAllTabs = function(){
		jQuery(this.tabs).each(function(){
			jQuery(this.tabId).hide();
			jQuery(this.parentNode).removeClass('active');
		});
	};

	controls.showTab = function(tab) {
		this.hideAllTabs();
		jQuery(tab.tabId).show();
		jQuery(tab.parentNode).addClass('active');
	};

	// Set up the links
	jQuery(controls).find('a').each(function(){
		this.container = controls;
		this.tabId = this.href.match(/(#[\w\d\-_]+)$/)[1];
		controls.tabs.push(this);
		jQuery(this).click(function(){
			this.container.showTab(this);
			return false;
		});
	});

	controls.hideAllTabs();
	
	var anchorTab = false;
	var tabShown  = false;
	if(document.location.toString().match(/(#[\w\d\-_]+)$/)){
		anchorTab = document.location.toString().match(/(#[\w\d\-_]+)$/)[1];
		for(a = 0; a < controls.tabs.length; a++){
			if(controls.tabs[a].tabId == anchorTab){
				controls.showTab(controls.tabs[a]);
				tabShown = true;
			}
		}
	}
	
	if(!tabShown && settings.showFirstTab){
		controls.showTab(controls.tabs[0]);
	}

	// Delegates
	this.controls = controls;
	this.tabs = this.controls.tabs;
}

/* Rich text editing */
function jRichTextArea(textArea, options) {
	this.textArea = textArea;

	// Default options
	settings = jQuery.extend({
	     className: "richTextToolbar"
	}, options);
	
	this.toolbar = {
		settings : settings,
		textArea : textArea,
		listElement : false,
		buttons : [],
		addButton : function(name, callback, options) {
			// Default options
			settings = jQuery.extend({
			     className: name.replace(/[\s]+/, '')+"Button"
			}, options);
			var li = document.createElement("li");
			var a = document.createElement("a");
			a.title = name;
			a.textArea = this.textArea;
			//callback.this = this;
			jQuery(a).click(callback);
			jQuery(a).addClass(settings.className);
			jQuery(li).append(a).appendTo(this.listElement);
			this.buttons.push(li);
			return this;
		},
		create : function() {
			if(!this.listElement) {
				this.listElement = document.createElement("ul");
				jQuery(this.listElement).addClass(this.settings.className);
				jQuery(this.listElement).insertBefore(this.textArea);
			}
		}
	};
	
	this.textArea.selectedText = function() {
		return jQuery(this).getSelection().text;
	};
	this.textArea.replaceSelection = function(replacement) {
		return jQuery(this).replaceSelection(replacement);
	};
	this.textArea.wrapSelection = function() {
		var prepend = arguments[0];
		var append = (arguments.length > 1) ? arguments[1] : prepend;
		return this.replaceSelection(prepend + this.selectedText() + append);
	};

	// Delegates
	this.textArea.toolbar = this.toolbar;
	this.toolbar.create();
}

var Sugar = {
	loadNewPosts : function(){
		var newPosts    = $('#newPosts').get()[0];
		var newPostsURL = $('#discussionLink').get()[0].href.match(/^(https?:\/\/[\w\d\.:]+\/discussions\/[\d]+)/)[1] + "/posts/since/"+newPosts.postsCount;

		$(newPosts).html('Loading&hellip;');

		$.get(newPostsURL, function(data){
			if($('.posts #ajaxPosts').length < 1) {
				$('.posts').append('<div id="ajaxPosts"></div>');
			}

			$('.posts #ajaxPosts').append(data);
			$('.posts #ajaxPosts .post:not(.shown)').hide().slideDown().addClass('shown');

			$('.shown_items_count').text(newPosts.serverPostsCount);
		});
		
		// Reset the notifier
		document.title = newPosts.documentTitle;
		newPosts.postsCount = newPosts.serverPostsCount;
		newPosts.shown = false;
		$(newPosts).fadeOut();

		this.applyPostFunctions();

		return false;
	},
	applyTabs : function(){
		jQuery('#reply-tabs').each(function(){
			window.replyTabs = new SugarTabs(this, {showFirstTab: false});
			if(jQuery('body.last_page').length > 0) {
				window.replyTabs.controls.showTab(window.replyTabs.tabs[0]);
			}
		});
		jQuery('#profile-tabs').each(function(){
			window.profileTabs = new SugarTabs(this, {showFirstTab: true});
		});
	},
	applyRichText : function() {
		jQuery('textarea.rich').each(function(){
			if(!this.toolbar){
				var ta = new jRichTextArea(this);

				// Setup the buttons
				ta.toolbar
					// Bold
					.addButton("Bold", function(){ this.textArea.wrapSelection('<strong>','</strong>'); })
					// Italic
					.addButton("Italics", function(){ this.textArea.wrapSelection('<em>','</em>'); })
					// Link
					.addButton("Link", function(){
					    var selection = this.textArea.selectedText();
					    var response = prompt('Enter link URL','');  
					    this.textArea.replaceSelection(
							'<a href="' + (response === '' ? 'http://link_url/' : response).replace(/^(?!(f|ht)tps?:\/\/)/,'http://') + '">' + 
							((selection==='') ? "Link text" : selection) + '</a>');
					})
					// Image tag
					.addButton("Image", function(){
					    var selection = this.textArea.selectedText();
						if( selection === '') {
						    var response = prompt('Enter image URL',''); 
						    if(response === null) { return; }
							this.textArea.replaceSelection('<img src="'+response+'" alt="" />');
						} else {
							this.textArea.replaceSelection('<img src="'+selection+'" alt="" />');
						}
					})
					// Block Quote
					.addButton("Block Quote", function(){ this.textArea.wrapSelection('<blockquote>','</blockquote>'); })
					// Escape HTML
					.addButton("Escape HTML", function(){
					    var selection = this.textArea.selectedText();
					    this.textArea.replaceSelection(selection.replace(/</g,'&lt;').replace(/>/g,'&gt;'));
					});
			}
		});
	},
	applyPostFunctions: function() {
		$('.quote_post').click(function(){
			var postId = this.id.match(/-([\d]+)$/)[1];
			window.quotePost(postId);
		});
		$('.edit_post').click(function(){
			var postID = this.id.match(/-([\d]+)$/)[1];
			var editURL = this.href;
			$("#postBody-"+postID).html('<span class="ticker">Loading...</span>');
			$("#postBody-"+postID).load(editURL, false, function(){
				Sugar.applyRichText();
			});
			return false;
		});
	},
	init : function() {
		this.applyTabs();
		this.applyRichText();
		
		// Observe the search mode selection box, set the proper action.
		jQuery('#search_mode').change(function(){
			this.parentNode.action = this.value;
		});
		
		// Detect discussion view
		if(jQuery('body.discussion').length > 0) {
			window.addToReply = function(string) {
				window.replyTabs.controls.showTab(window.replyTabs.tabs[0]);
				jQuery('#compose-body').val(jQuery('#compose-body').val() + string);
			};
		}

		// Post quoting
		window.quotePost = function(postId){
			
			var postDiv = '#post-'+postId;
			if(jQuery(postDiv).length > 0) {
				var permalink  = '';
				var username   = '';
				var content    = '';
				var quotedPost = '';
				if(jQuery(postDiv).hasClass('me_post')) {
					username  = jQuery(postDiv+' .body .poster').text();
					content   = jQuery(postDiv+' .body .content').html()
						.replace(/^[\s]*/, '')
						.replace(/[\s]*$/, '')
						.replace(/<br[\s\/]*>/g, "\n");
					quotedPost = '<blockquote><cite>Posted by '+username+':</cite>'+content+'</blockquote>';
				} else {
					permalink = jQuery(postDiv+' .post_info .permalink a').get()[0].href.replace(/^https?:\/\/([\w\d\.:\-]*)/,'');
					username  = jQuery(postDiv+' .post_info .username a').text();
					content   = jQuery(postDiv+' .body .content').html()
						.replace(/^[\s]*/, '')
						.replace(/[\s]*$/, '')
						.replace(/<br[\s\/]*>/g, "\n");
					quotedPost = '<blockquote><cite>Posted by <a href="'+permalink+'">'+username+'</a>:</cite>'+content+'</blockquote>';
				}
				addToReply(quotedPost);
			}
		};
		
		this.applyPostFunctions();
		
		// Detect Napkin
		if(jQuery('#napkin').length > 0) {

			// Setup callbacks
			window.uploadDrawing = function() {
				jQuery('#napkin-submit').text("Posting, please wait...");
				swfobject.getObjectById("napkin").uploadDrawing();
			};
			window.onDrawingUploaded = function(url) {
				window.location.reload();
			};

			// Make napkins clickable
			jQuery('.drawing img').each(function(){
				jQuery(this).click(function() {
					if(swfobject.getObjectById("napkin")) {
						swfobject.getObjectById("napkin").setBackground(this.src);
					}
				});
			});
		}
		
		// Refresh posts count
		if( $('.total_items_count').length > 0 && $('#newPosts').length > 0){
			var newPosts = $('#newPosts').get()[0];
			newPosts.postsCount = $('.total_items_count').eq(0).text();
			newPosts.postsCountUrl = $('#discussionLink').get()[0].href.match(/^(https?:\/\/[\w\d\.:]+\/discussions\/[\d]+)/)[1] + "/posts/count.js";
			newPosts.documentTitle = document.title;
			newPosts.refreshInterval = setInterval(function(){
				$.getJSON(newPosts.postsCountUrl, function(json) {
					if(json.posts_count > newPosts.postsCount){
						var newPostsSinceRefresh = json.posts_count - newPosts.postsCount;
						$('.total_items_count').text(json.posts_count);
						if(newPostsSinceRefresh > 50) {
							$(newPosts).html('<p>New posts have been made since this page was loaded, reload the page to see them.</p>');
							document.title = "[New posts] "+newPosts.documentTitle;
							clearInterval(newPosts.refreshInterval);
						} else {
							var newPostsString = "A new post has";
							if(newPostsSinceRefresh == 1) {
								document.title = "["+newPostsSinceRefresh+" new post] "+newPosts.documentTitle;
							} else {
								newPostsString = newPostsSinceRefresh+" new posts have";
								document.title = "["+newPostsSinceRefresh+" new posts] "+newPosts.documentTitle;
							}
							if($('body.last_page').length > 0){
								$(newPosts).html('<p>'+newPostsString+' been made since this page was loaded, <a href="'+$('#discussionLink').get()[0].href+'" onclick="Sugar.loadNewPosts(); return false;">click here to load</a>.</p>');
							} else {
								$(newPosts).html('<p>'+newPostsString+' been made since this page was loaded, move on to the last page to see them.</p>');
							}
							newPosts.serverPostsCount = json.posts_count;
						}
						if(!newPosts.shown) {
							$(newPosts).addClass('new_posts_since_refresh').hide().slideDown();
							newPosts.shown = true;
						}
					}
				});
			}, 5000);
		}

		// Load tweets
		$('#profileTweets').each(function(){
			var tweetsDiv = this;
			var username = $(this.parentNode).find('.username').get()[0].innerHTML.replace(/^@/, '');
			var user_info_url = "http://twitter.com/users/show/"+username+".json?callback=?";
			var updates_url = "http://twitter.com/statuses/user_timeline/"+username+".json?count=5&callback=?";
			$.getJSON(user_info_url, function(user_json) {
				var protectedMode = 'protected';
				if(user_json[protectedMode]) {
					$(tweetsDiv).html("<p>Updates are protected</p>");
				} else {
					$.getJSON(updates_url, function(json) {
						$(json).each(function(){
							var linkified_text = this.text.replace(/[A-Za-z]+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:%&\?\/.=]+/, function(m) { return m.link(m); });
							linkified_text = linkified_text.replace(/@[A-Za-z0-9_]+/, function(u){return u.link('http://twitter.com/'+u.replace(/^@/,''));});
							$(tweetsDiv).append('<div class="tweet tweet-'+this.id+'">' + '<p class="text">' + linkified_text + ' <a href="http://twitter.com/'+username+'/statuses/'+this.id+'" class="time">'+relativeTime(this.created_at)+'</a>' + '</p>' + '</div>');
						});
					});
				}
			});
		});
		
		// Load Flickr photos
		$('#flickrProfileURL').each(function(){
			var fuid = this.href.split("/");
			fuid = fuid[(fuid.length-1)];
			jQuery(function(){   
				$('#flickrPhotos').hide();
			  	jQuery("#flickrPhotos").flickr({
			    	api_key: "016918184821edf95505d9acd61e64c4",
					type: 'search',
					user_id: fuid,
					per_page: 15,
					callback: function(list){
						$('#flickrPhotos').show();
					}
				}); 
			});	
		});
	}
};

jQuery(document).ready(function() {
	Sugar.init();
});
