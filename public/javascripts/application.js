/**
 * @depends jquery.libraries.js
 */

/* Dead simple tabs */
function B3STabs(controls, options) {
	controls.tabs = [];
	
	settings = jQuery.extend({
		showFirstTab: true
	}, options);

	controls.hideAllTabs = function(){
		jQuery(this.tabs).each(function(){
			jQuery(this.tabId).hide();
			jQuery(this).removeClass('active');
		});
	};

	controls.showTab = function(tab) {
		this.hideAllTabs();
		jQuery(tab.tabId).show();
		jQuery(tab).addClass('active');
	};

	// Set up the links
	jQuery(controls).find('a').each(function(){
		this.container = controls;
		this.tabId = this.href.match(/(#[\w\d\-_]+)$/)[1];
		controls.tabs.push(this);
		jQuery(this).click(function(){
			this.container.showTab(this);
			return true;
		});
	});

	controls.hideAllTabs();
	if(settings.showFirstTab){
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

var B3S = {
	applyTabs : function(){
		jQuery('#reply-tabs').each(function(){
			window.replyTabs = new B3STabs(this, {showFirstTab: false});
			if(jQuery('body.last_page').length > 0) {
				window.replyTabs.controls.showTab(window.replyTabs.tabs[0]);
			}
		});
	},
	applyRichText : function() {
		jQuery('textarea.rich').each(function(){
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
				var permalink = jQuery(postDiv+' .post_info .permalink a').get()[0].href.replace(/^https?:\/\/([\w\d\.:\-]*)/,'');
				var username  = jQuery(postDiv+' .post_info .username a').text();
				var content   = jQuery(postDiv+' .body .content').html()
					.replace(/^[\s]*/, '')
					.replace(/[\s]*$/, '')
					.replace(/<br[\s\/]*>/g, "\n");
				var quotedPost = '<blockquote><cite>Posted by <a href="'+permalink+'">'+username+'</a>:</cite>'+content+'</blockquote>';
				addToReply(quotedPost);
			}
		};


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

	}
};

jQuery(document).ready(function() {
	B3S.init();
});
