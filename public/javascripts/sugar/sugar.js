var Sugar = {
	Configuration: {},
	Initializers: {

		usersMap : function() {
			$('#usersMap').each(function(){
				var map = new GMap2(this);
				var defaultLocation = new GLatLng(46.073231,-32.343750);
				map.addControl(new GLargeMapControl());
				map.addControl(new GMapTypeControl());
				map.setCenter(defaultLocation, 3);

				var usersAPIurl = '/users.json';
					$.getJSON(usersAPIurl, function(json) {
						$(json).each(function(){
							var user = this.user;
							if(user.latitude && user.longitude) {
								var position = new GLatLng(user.latitude, user.longitude);
								var marker = new GMarker(position);
								GEvent.addListener(marker, "click", function() {
									marker.openInfoWindowHtml(
										"<strong>"+user.username+"</strong><br />" +
										((user.realname) ? user.realname+"<br />" : "") +
										"<a href=\"/users/profile/"+user.username+"\">View profile</a>");
								});
								map.addOverlay(marker);
							}
						});
					});
				});
		},

		editProfileMap : function() {
			$('#editProfileMap').each(function(){

				var map = new GMap2(this);
				var defaultLocation = new GLatLng(46.073231,-32.343750);
				map.addControl(new GLargeMapControl());
				map.addControl(new GMapTypeControl());

				var updatePosition = function(latlng){
					$('#user_latitude').val(latlng.lat());
					$('#user_longitude').val(latlng.lng());
				};

				var userMarker = false;
				var createUserMarker = function(latlng){
					userMarker = new GMarker(latlng, {draggable:true});
					map.addOverlay(userMarker);
					GEvent.addListener(userMarker, "click", function() {
						map.setCenter(userMarker.getLatLng());
					});
					GEvent.addListener(userMarker, "dragend", function() {
						updatePosition(userMarker.getLatLng());
					});
				};

				window.clearLocation = function(){
					$('#user_latitude').val('');
					$('#user_longitude').val('');
					map.removeOverlay(userMarker);
					userMarker = false;
				};


				if(!$('#user_latitude').val() || !$('#user_latitude').val()) {
					map.setCenter(defaultLocation, 2);
				} else {
					var location = new GLatLng($('#user_latitude').val(), $('#user_longitude').val());
					map.setCenter(location, 10);
					createUserMarker(location);
				}

				GEvent.addListener(map, "click", function(overlay, latlng) {
					if(!userMarker) {
						updatePosition(latlng);
						createUserMarker(latlng);
					}
				});
			});
		},

		richText : function() {
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

		searchMode: function(){
			// Observe the search mode selection box, set the proper action.
			jQuery('#search_mode').change(function(){
				this.parentNode.action = this.value;
			});
		},

		tabs: function(){
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

		postFunctions: function() {
			$('.quote_post').click(function(){
				var postId = this.id.match(/-([\d]+)$/)[1];
				window.quotePost(postId);
			});
			$('.edit_post').click(function(){
				var postID = this.id.match(/-([\d]+)$/)[1];
				var editURL = this.href;
				$("#postBody-"+postID).html('<span class="ticker">Loading...</span>');
				$("#postBody-"+postID).load(editURL, false, function(){
					Sugar.Initializers.richText();
				});
				return false;
			});
		},
		
		napkin: function(){
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
		},

		profileTweets: function(){
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
		},
		
		profileFlickr: function(){
			if(Sugar.Configuration.FlickrAPI){
				$('#flickrProfileURL').each(function(){
					var fuid = this.href.split("/");
					fuid = fuid[(fuid.length-1)];
					jQuery(function(){   
						$('#flickrPhotos').hide();
					  	jQuery("#flickrPhotos").flickr({
					    	api_key: Sugar.Configuration.FlickrAPI,
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
		},
		
		parsePosts: function(){
			$("#replyText form").submit(function(){
				var submitForm = this;
				var statusField = $('#button-container');
				var oldPostButton = statusField.html();
				statusField.addClass('posting');

				statusField.html('Validating post..');

				var postBody = $('#compose-body').val();

				if($('#hiddenPostVerifier').length < 1) {
					$(document.body).append('<div id="hiddenPostVerifier"></div>');
				}
				var postNotifier = $('#hiddenPostVerifier');
				postNotifier.show();
				postNotifier.html(postBody);
				postNotifier.hide();

				var postImages = postNotifier.find('img');
				var loadedImages = Array();
				if(postImages.length > 0) {

					// Async loading event
					postImages.each(function(){
						$(this).load(function(){
							loadedImages.push(this);
						});
					});

					// Check loading of images
					postNotifier.cycles = 0;
					postNotifier.loadInterval = setInterval(function(){
						postNotifier.cycles += 1;
						statusField.html('Loading image '+loadedImages.length+' of '+postImages.length+'..');

						// Load failed
						if(postNotifier.cycles >= 80) {
							clearInterval(postNotifier.loadInterval);
							if(confirm("One or more of your images timed out. Post anyway?")) {
								$(loadedImages).each(function(){
									$(this).attr('height', this.height);
									$(this).attr('width', this.width);
								});
								$('#compose-body').val(postNotifier.html());
								statusField.html('Saving post...');
								submitForm.submit();
							} else {
								statusField.html(oldPostButton);
								statusField.removeClass('posting');
							}
						}

						// All images loaded
						if(loadedImages.length == postImages.length) {
							postImages.each(function(){
								$(this).attr('height', this.height);
								$(this).attr('width', this.width);
							});
							$('#compose-body').val(postNotifier.html());
							clearInterval(postNotifier.loadInterval);
							statusField.html('Saving post...');
							submitForm.submit();
						}
					}, 100);
					return false;
				} else {
					return true;
				}
			});
		},

		newPostsCount: function(){
			if( $('.total_items_count').length > 0 && $('#newPosts').length > 0 && $('body.last_page').length > 0){
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
		}
	},

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

		return false;
	},

	init : function() {
		for(var initializer in this.Initializers) {
			if(this.Initializers.hasOwnProperty(initializer)){
				this.Initializers[initializer]();
			}
		}

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
		
	}
};
