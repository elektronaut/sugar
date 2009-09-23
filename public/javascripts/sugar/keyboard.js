$.extend(Sugar.Initializers, {
	enableKeyboardNavigator: function(){
		if(Sugar.Configuration.KeyboardShortcuts){
			Sugar.KeyboardNavigator.apply();
		}
	}
});

Sugar.KeyboardNavigator = {
	defaultTarget: false,
	targets: [],
	currentTarget: false,
	keySequence: '',
    specialKeys: { 27: 'esc', 9: 'tab', 32:'space', 13: 'return', 8:'backspace', 145: 'scroll', 
        20: 'capslock', 144: 'numlock', 19:'pause', 45:'insert', 36:'home', 46:'del',
        35:'end', 33: 'pageup', 34:'pagedown', 37:'left', 38:'up', 39:'right',40:'down', 
        112:'f1',113:'f2', 114:'f3', 115:'f4', 116:'f5', 117:'f6', 118:'f7', 119:'f8', 
        120:'f9', 121:'f10', 122:'f11', 123:'f12', 191: '/',
		96: '0', 97:'1', 98: '2', 99: '3', 100: '4', 101: '5', 102: '6', 103: '7', 104: '8', 105: '9', 106: '*', 
		107: '+', 109: '-', 110: '.', 111 : '/'
	},
	
	apply: function(){
		if($('table.discussions').length > 0){
			this.applyDiscussionsHotkeys();
		}
		if($('.posts .post').length > 0){
			this.applyPostsHotkeys();
		}
		this.applyGlobalHotkeys();
	},
	
	addTarget: function(target, targetId){
		if($.inArray(target, this.targets) < 0){
			$(target).data('targetId', targetId);
			this.targets[this.targets.length] = target;
		}
	},
	
	getTarget: function(){
		return((this.currentTarget) ? this.currentTarget : false);
	},

	scrollTo: function(target){
		var targetPosition = $(target).offset().top;
		var bottom = $(window).height() + $(window).scrollTop();

		if(targetPosition > bottom || targetPosition < $(window).scrollTop() || (targetPosition + $(target).height()) > bottom){
		 	$.scrollTo(target, {duration: 100, offset: { top: -50, left:0 }, axis: 'y'});
		}
	},
	
	gotoTarget: function(target){
		this.currentTarget = target;
		$(this).trigger('targetchanged', [target]);
	},
	
	gotoNextTarget: function(){
		if(!this.currentTarget) {
			if(this.defaultTarget){
				this.gotoTarget(this.defaultTarget);
			} else {
				this.gotoTarget(this.targets[0]);
			}
		} else {
			var index = $.inArray(this.currentTarget, this.targets) + 1;
			if(index >= this.targets.length){
				index = 0;
			}
			this.gotoTarget(this.targets[index]);
		}
	},
	
	gotoPrevTarget: function(){
		if(!this.currentTarget) {
			if(this.defaultTarget){
				this.gotoTarget(this.defaultTarget);
				this.gotoPrevTarget();
			} else {
				this.gotoTarget(this.targets[this.targets.length - 1]);
			}
		} else {
			var index = $.inArray(this.currentTarget, this.targets) - 1;
			if(index < 0){
				index = this.targets.length - 1;
			}
			this.gotoTarget(this.targets[index]);
		}
	},


	findElement: function (elem){
        if (!jQuery(elem).attr('hkId')){
            if (jQuery.browser.opera || jQuery.browser.safari){
                while (!jQuery(elem).attr('hkId') && elem.parentNode){
                    elem = elem.parentNode;
                }
            }
        }
        return elem;
    },

	// Global hotkeys
	applyGlobalHotkeys: function(){
		var keynav = this;

		// Pagination
		var gotoPrevPage = function(event){
			if(!event.metaKey && $('.prev_page_link').length > 0){
				document.location = $('.prev_page_link').get(0).href;
			}
		};
		var gotoNextPage = function(event){
			if(!event.metaKey && $('.next_page_link').length > 0){
				document.location = $('.next_page_link').get(0).href;
			}
		};
		$(document).bind('keydown', {combi: 'shift+p', disableInInput: true}, gotoPrevPage);
		$(document).bind('keydown', {combi: 'shift+k', disableInInput: true}, gotoPrevPage);
		$(document).bind('keydown', {combi: 'shift+n', disableInInput: true}, gotoNextPage);
		$(document).bind('keydown', {combi: 'shift+j', disableInInput: true}, gotoNextPage);
		$(document).bind('keydown', {combi: 'u', disableInInput: true}, function(event){
			if(!event.metaKey && $('#back_link').length > 0){
				document.location = $('#back_link').get(0).href;
				return false;
			}
		});

		// Listen for sequences
		$(document).bind('keydown', function(event){
			var target = $(event.target);
			var character = !keynav.specialKeys[event.which] && String.fromCharCode(event.keyCode).toLowerCase();
			if(event.shiftKey && event.which >= 65 && event.which <= 90) {
				character = character.toUpperCase();
			}
			if (target.is("input") || target.is("textarea") || target.is("select") ){
				keynav.keySequence = '';
			} else {
				if(!event.metaKey && character && character.match(/^[\w\d]$/)){
					keynav.keySequence += character;
					keySequence = keynav.keySequence = keynav.keySequence.match(/([\w\d]{0,5})$/)[1]; // Limit to 5 keys
					var shortcuts = {
						'#discussions_link': /gd$/,
						'#following_link':   /gf$/,
						'#favorites_link':   /gF$/,
						'#categories_link':  /gc$/,
						'#messages_link':    /gm$/,
						'#invites_link':     /gi$/,
						'#users_link':       /gu$/
					};
					for(var selector in shortcuts){
						if(keySequence.match(shortcuts[selector]) && $(selector).length > 0){ 
							document.location = $(selector).get(0).href;
						}
					}
				}
			}
		});
	},
	
	// Hotkeys for posts list
	applyPostsHotkeys: function(){
		var keynav = this;

		$('.posts .post').each(function(){
			keynav.addTarget(this, this.id.match(/(post|message)\-([\d]+)/)[2]);
		});
		$(document).bind('postsloaded', function(){
			$('.posts .post').each(function(){
				keynav.addTarget(this, this.id.match(/(post|message)\-([\d]+)/)[1]);
			});
		});

		// Set target post
		if(document.location.toString().match(/#(post|message)-([\d]+)/)){
			this.defaultTarget = $('#post-'+document.location.toString().match(/#(post|message)-([\d]+)/)[2]).get(0);
		} else {
			// Go to the first direct post, skipping the ones in .context
			this.defaultTarget = $('.posts > .post').get(0);
		}

		// Target changed event
		$(this).bind('targetchanged', function(e, target){
			$('.posts .post').removeClass('targeted');
			$(target).addClass('targeted');
			this.scrollTo(target);
		});

		$(document).bind('keydown', {combi: 'p', disableInInput: true}, function(event){if(!event.metaKey){keynav.gotoPrevTarget();}});
		$(document).bind('keydown', {combi: 'k', disableInInput: true}, function(event){if(!event.metaKey){keynav.gotoPrevTarget();}});
		$(document).bind('keydown', {combi: 'n', disableInInput: true}, function(event){if(!event.metaKey){keynav.gotoNextTarget();}});
		$(document).bind('keydown', {combi: 'j', disableInInput: true}, function(event){if(!event.metaKey){keynav.gotoNextTarget();}});
		$(document).bind('keydown', {combi: 'r', disableInInput: true}, function(event){if(!event.metaKey){Sugar.loadNewPosts();}});
		$(document).bind('keydown', {combi: 'c', disableInInput: true}, function(event){
			if(!event.metaKey && $('#replyText textarea').length > 0){
				$('#replyText textarea').focus();
				return false;
			}
		});
		$(document).bind('keydown', {combi: 'q', disableInInput: true}, function(event){
			if(!event.metaKey && keynav.getTarget()){
				Sugar.quotePost($(keynav.getTarget()).data('targetId'));
				return false;
			}
		});
	},

	// Hotkeys for discussions list
	applyDiscussionsHotkeys: function(){
		var keynav = this;
		
		$(this).bind('targetchanged', function(e, target){
			$('tr.discussion').removeClass('targeted');
			$('tr.discussion'+$(target).data('targetId')).addClass('targeted');
			$('tr.conversation').removeClass('targeted');
			$('tr.conversation'+$(target).data('targetId')).addClass('targeted');
			this.scrollTo(target);
		});

		$('table.discussions td.name a').each(function(){
			keynav.addTarget(this, this.parentNode.parentNode.className.match(/(discussion|conversation)([\d]+)/)[2]);
		});
		
		var openTarget = function(openInNewTab){
			if(keynav.currentTarget) {
				var targetUrl = keynav.currentTarget.href;
				if(openInNewTab){
					window.open(targetUrl);
				} else {
					document.location = targetUrl;
				}
			}
		};

		var markAsRead = function(event){
			if(!event.metaKey && keynav.currentTarget && $(keynav.currentTarget.parentNode.parentNode).hasClass('discussion')) {
				var target = keynav.currentTarget;
				var targetId = $(target).data('targetId');
				var url = '/discussions/'+targetId+'/mark_as_read';
				$.get(url, {}, function(){
					$('.discussion'+targetId).removeClass('new_posts');
					$('.discussion'+targetId+' .new_posts').html('');
				});
			}
		};

		$(document).bind('keydown', {combi: 'p', disableInInput: true}, function(event){if(!event.metaKey){keynav.gotoPrevTarget();}});
		$(document).bind('keydown', {combi: 'k', disableInInput: true}, function(event){if(!event.metaKey){keynav.gotoPrevTarget();}});
		$(document).bind('keydown', {combi: 'n', disableInInput: true}, function(event){if(!event.metaKey){keynav.gotoNextTarget();}});
		$(document).bind('keydown', {combi: 'j', disableInInput: true}, function(event){if(!event.metaKey){keynav.gotoNextTarget();}});
		$(document).bind('keydown', {combi: 'o', disableInInput: true}, function(event){if(!event.metaKey){openTarget(false);}});
		$(document).bind('keydown', {combi: 'shift+o', disableInInput: true}, function(event){if(!event.metaKey){openTarget(true);}});
		$(document).bind('keydown', {combi: 'Return', disableInInput: true}, function(event){if(!event.metaKey){openTarget(false);}});
		$(document).bind('keydown', {combi: 'shift+Return', disableInInput: true}, function(event){if(!event.metaKey){openTarget(true);}});
		$(document).bind('keydown', {combi: 'y', disableInInput: true}, markAsRead);
		$(document).bind('keydown', {combi: 'm', disableInInput: true}, markAsRead);

		// New discussion/category
		$(document).bind('keydown', {combi: 'c', disableInInput: true}, function(event){
			if(!event.metaKey && $('.functions .create').length > 0){
				document.location = $('.functions .create').get(0).href;
			}
		});
	}
};


