var Sugar = {
	Configuration: {},
	onLoadedPosts: {},
	Initializers: {

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
						// MP3 Player
						.addButton("MP3", function(){
							var selection = this.textArea.selectedText();
						    var response = prompt('Enter MP3 URL','');  
							if(selection===''){
								selection = prompt('Enter track title', '');
							}
						    this.textArea.replaceSelection(
								'<a href="' + (response === '' ? 'http://link_url/' : response).replace(/^(?!(f|ht)tps?:\/\/)/,'http://') + '" class="mp3player">' + 
								((selection==='') ? "Link text" : selection) + '</a>');
						})
						// Block Quote
						.addButton("Block Quote", function(){ this.textArea.wrapSelection('<blockquote>','</blockquote>'); })
						// Escape HTML
						.addButton("Escape HTML", function(){
						    var selection = this.textArea.selectedText();
							var response = prompt('Enter language (leave blank for no syntax highlighting)','');
							if(response) {
								this.textArea.replaceSelection('<code language="'+response+'">'+selection+'</code>');
							} else {
							    this.textArea.replaceSelection('<code>'+selection+'</code>');
							}
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
			$('.quote_post').each(function(){
				if(!this.functionalityApplied) {
					$(this).click(function(){
						var postId = this.id.match(/-([\d]+)$/)[1];
						window.quotePost(postId);
					});
					this.functionalityApplied = true;
				}
			});
			$('.edit_post').each(function(){
				if(!this.functionalityApplied) {
					$(this).click(function(){
						var postID = this.id.match(/-([\d]+)$/)[1];
						var editURL = this.href;
						$("#postBody-"+postID).html('<span class="ticker">Loading...</span>');
						$("#postBody-"+postID).load(editURL, null, function(){
							Sugar.Initializers.richText();
						});
						return false;
					});
					this.functionalityApplied = true;
				}
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
		
		newPostsCount: function(){
			if($('.total_items_count').length > 0 && $('#newPosts').length > 0 && $('body.last_page').length > 0){
				Sugar.updateNewPostsCounter();
			}
		}
		
	},
	
	updateNewPostsCounter : function(){
		var newPosts = $('#newPosts').get()[0];
		newPosts.postsCount = parseInt($('.total_items_count').eq(0).text(), 10);
		if(!newPosts.originalCount) {
			newPosts.originalCount = newPosts.postsCount;
		}
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
	},
	
	loadNewPosts : function(){
		var newPosts    = $('#newPosts').get()[0];
		var newPostsURL = $('#discussionLink').get()[0].href.match(/^(https?:\/\/[\w\d\.:]+\/discussions\/[\d]+)/)[1] + "/posts/since/"+newPosts.postsCount;

		$(newPosts).html('Loading&hellip;');
		$(newPosts).addClass('new_posts_since_refresh');

		clearInterval(newPosts.refreshInterval);

		$.get(newPostsURL, function(data){
			$(newPosts).hide();

			if($('.posts #ajaxPosts').length < 1) {
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
			Sugar.updateNewPostsCounter();

			for(var f in Sugar.onLoadedPosts) {
				if(Sugar.onLoadedPosts.hasOwnProperty(f)){
					Sugar.onLoadedPosts[f]();
				}
			}
		});
		
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

		window.deparsePost = function(content){
			content = content
				.replace(/^[\s]*/, '')          // Strip leading space
				.replace(/[\s]*$/, '')          // Strip trailing space
				.replace(/<br[\s\/]*>/g, "\n"); // Change <br /> to line breaks
			if(content.match(/<div class="codeblock/)){
				if($('#hiddenPostDeparser').length < 1) {
					$(document.body).append('<div id="hiddenPostDeparser"></div>');
				}
				var hiddenBlock = $('#hiddenPostDeparser');
				hiddenBlock.show();
				hiddenBlock.html(content);
				hiddenBlock.hide();
				
				// Remove line numbers
				$(hiddenBlock).find('.codeblock .line-numbers').remove();
				$(hiddenBlock).find('.codeblock').each(function(){
					var codeLanguage = this.className.match(/language_([\w\d\-\.\+_]+)/)[1];
					blockContent = $(this).children('pre').text().replace(/^[\s]*/, '').replace(/[\s]*$/, '');
					$(this).replaceWith('<code language="'+codeLanguage+'">'+blockContent+'</code>');
				});
				
				content = hiddenBlock.html();
				hiddenBlock.html('');
				content = content
					.replace("<code", "</blockquote>\n<code")
					.replace("</code>", "</code><blockquote>");
			}
			return content;
		};
		
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
					content   = window.deparsePost(jQuery(postDiv+' .body .content').html());
					quotedPost = '<blockquote><cite>Posted by <a href="'+permalink+'">'+username+'</a>:</cite>'+content+'</blockquote>';
					// Trim empty blockquotes
					while(quotedPost.match(/<blockquote>[\s]*<\/blockquote>/)){
						quotedPost = quotedPost.replace(/<blockquote>[\s]*<\/blockquote>/, '')
					}
				}
				addToReply(quotedPost);
			}
		};
		
	}
};
