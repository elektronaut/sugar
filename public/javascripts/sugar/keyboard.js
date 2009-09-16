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
	
	apply: function(){
		this.applyGlobalHotkeys();
		if($('table.discussions').length > 0){
			this.applyDiscussionsHotkeys();
		}
		if($('.posts .post').length > 0){
			this.applyPostsHotkeys();
		}
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

	// Global hotkeys
	applyGlobalHotkeys: function(){
		// Pagination
		var gotoPrevPage = function(){
			if($('.prev_page_link').length > 0){
				document.location = $('.prev_page_link').get(0).href;
			}
		}
		var gotoNextPage = function(){
			if($('.next_page_link').length > 0){
				document.location = $('.next_page_link').get(0).href;
			}
		}
		$(document).bind('keydown', {combi: 'shift+p', disableInInput: true}, gotoPrevPage);
		$(document).bind('keydown', {combi: 'shift+k', disableInInput: true}, gotoPrevPage);
		$(document).bind('keydown', {combi: 'shift+n', disableInInput: true}, gotoNextPage);
		$(document).bind('keydown', {combi: 'shift+j', disableInInput: true}, gotoNextPage);
		$(document).bind('keydown', {combi: 'u', disableInInput: true}, function(){
			if($('#back_link').length > 0){
				document.location = $('#back_link').get(0).href;
			}
			return false;
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
			$('.posts .post').removeClass('targetted');
			$(target).addClass('targetted');
			this.scrollTo(target);
		});

		$(document).bind('keydown', {combi: 'p', disableInInput: true}, function(){keynav.gotoPrevTarget();});
		$(document).bind('keydown', {combi: 'k', disableInInput: true}, function(){keynav.gotoPrevTarget();});
		$(document).bind('keydown', {combi: 'n', disableInInput: true}, function(){keynav.gotoNextTarget();});
		$(document).bind('keydown', {combi: 'j', disableInInput: true}, function(){keynav.gotoNextTarget();});
		$(document).bind('keydown', {combi: 'r', disableInInput: true}, function(){Sugar.loadNewPosts();});
		$(document).bind('keydown', {combi: 'c', disableInInput: true}, function(){
			if($('#replyText textarea').length > 0){
				$('#replyText textarea').focus();
			}
			return false;
		});
		$(document).bind('keydown', {combi: 'q', disableInInput: true}, function(){
			if(keynav.getTarget()){
				Sugar.quotePost($(keynav.getTarget()).data('targetId'));
			}
			return false;
		});
	},

	// Hotkeys for discussions list
	applyDiscussionsHotkeys: function(){
		var keynav = this;
		
		$(this).bind('targetchanged', function(e, target){
			$('tr.discussion').removeClass('targetted');
			$('tr.discussion'+$(target).data('targetId')).addClass('targetted');
			$('tr.conversation').removeClass('targetted');
			$('tr.conversation'+$(target).data('targetId')).addClass('targetted');
			this.scrollTo(target);
		});

		$('table.discussions td.name a').each(function(){
			keynav.addTarget(this, this.parentNode.parentNode.className.match(/(discussion|conversation)([\d]+)/)[2]);
		});
		
		var openTarget = function(){
			if(keynav.currentTarget) {
				document.location = keynav.currentTarget.href;
			}
		}

		var markAsRead = function(){
			if(keynav.currentTarget && $(keynav.currentTarget.parentNode.parentNode).hasClass('discussion')) {
				var target = keynav.currentTarget;
				var targetId = $(target).data('targetId');
				var url = '/discussions/'+targetId+'/mark_as_read';
				$.get(url, {}, function(){
					$('.discussion'+targetId).removeClass('new_posts');
					$('.discussion'+targetId+' .new_posts').html('');
				});
			}
		}

		$(document).bind('keydown', {combi: 'p', disableInInput: true}, function(){keynav.gotoPrevTarget();});
		$(document).bind('keydown', {combi: 'k', disableInInput: true}, function(){keynav.gotoPrevTarget();});
		$(document).bind('keydown', {combi: 'n', disableInInput: true}, function(){keynav.gotoNextTarget();});
		$(document).bind('keydown', {combi: 'j', disableInInput: true}, function(){keynav.gotoNextTarget();});
		$(document).bind('keydown', {combi: 'o', disableInInput: true}, openTarget);
		$(document).bind('keydown', {combi: 'Return', disableInInput: true}, openTarget);
		$(document).bind('keydown', {combi: 'y', disableInInput: true}, markAsRead);
		$(document).bind('keydown', {combi: 'm', disableInInput: true}, markAsRead);

		// New discussion/category
		$(document).bind('keydown', {combi: 'c', disableInInput: true}, function(){
			if($('.functions .create').length > 0){
				document.location = $('.functions .create').get(0).href;
			}
		});
	}
}


