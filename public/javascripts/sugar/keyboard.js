$.extend(Sugar.Initializers, {
	enableKeyboardNavigator: function(){
		if(Sugar.Configuration.KeyboardShortcuts){
			Sugar.KeyboardNavigator.apply();
		}
	}
});

Sugar.KeyboardNavigator = {
	targets: [],
	currentTarget: false,
	
	apply: function(){
		Sugar.KeyboardNavigator.applyGlobalHotkeys();
		if($('table.discussions').length > 0){
			Sugar.KeyboardNavigator.applyDiscussionsHotkeys();
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
	},

	// Hotkeys for discussions list
	applyDiscussionsHotkeys: function(){
		$('table.discussions td.name a').each(function(){
			Sugar.KeyboardNavigator.targets[Sugar.KeyboardNavigator.targets.length] = this;
			this.discussionId = this.parentNode.parentNode.className.match(/discussion([\d]+)/)[1];
		});

		var gotoTarget = function(target){
			Sugar.KeyboardNavigator.currentTarget = target;
			$('tr.discussion').removeClass('targetted_discussion');
			$('tr.discussion'+target.discussionId).addClass('targetted_discussion');
			
			var targetPosition = $(target).offset().top;
			var bottom = $(window).height() + $(window).scrollTop();
			if(targetPosition > bottom || targetPosition < $(window).scrollTop()){
				$.scrollTo(target, {duration: 100, offset: { top: -50, left:0 }, axis: 'y'});
			}
			
			//$.scrollTo(target, {duration: 300, offset: { top: -100, left:0 }, axis: 'y'});
			//console.log($(target).offset().top);
		}
		var gotoNextTarget = function(){
			if(!Sugar.KeyboardNavigator.currentTarget) {
				gotoTarget(Sugar.KeyboardNavigator.targets[0]);
			} else {
				var index = $.inArray(Sugar.KeyboardNavigator.currentTarget, Sugar.KeyboardNavigator.targets) + 1;
				if(index >= Sugar.KeyboardNavigator.targets.length){
					index = 0;
				}
				gotoTarget(Sugar.KeyboardNavigator.targets[index]);
			}
		}
		var gotoPrevTarget = function(){
			if(!Sugar.KeyboardNavigator.currentTarget) {
				gotoTarget(Sugar.KeyboardNavigator.targets[Sugar.KeyboardNavigator.targets.length - 1]);
			} else {
				var index = $.inArray(Sugar.KeyboardNavigator.currentTarget, Sugar.KeyboardNavigator.targets) - 1;
				if(index < 0){
					index = Sugar.KeyboardNavigator.targets.length - 1;
				}
				gotoTarget(Sugar.KeyboardNavigator.targets[index]);
			}
		}
		var openTarget = function(){
			if(Sugar.KeyboardNavigator.currentTarget) {
				document.location = Sugar.KeyboardNavigator.currentTarget.href;
			}
		}
		var markAsRead = function(){
			if(Sugar.KeyboardNavigator.currentTarget) {
				var target = Sugar.KeyboardNavigator.currentTarget;
				var url = '/discussions/'+target.discussionId+'/mark_as_read';
				$.get(url, {}, function(){
					$('.discussion'+target.discussionId).removeClass('new_posts');
					$('.discussion'+target.discussionId+' .new_posts').html('');
				});
			}
		}

		$(document).bind('keydown', {combi: 'p', disableInInput: true}, gotoPrevTarget);
		$(document).bind('keydown', {combi: 'k', disableInInput: true}, gotoPrevTarget);
		$(document).bind('keydown', {combi: 'n', disableInInput: true}, gotoNextTarget);
		$(document).bind('keydown', {combi: 'j', disableInInput: true}, gotoNextTarget);
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


