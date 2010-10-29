function toggleNavigation() {
	$('#navigation').toggle();
}

function resizeYoutube(){
	$('embed[src*=youtube.com]').each(function(){
		if(!this.originalHeight){
			this.originalHeight = this.height;
		}
		if(!this.originalWidth){
			this.originalWidth = this.width;
		}
		var maxWidth = window.innerWidth - 20;
		var maxHeight = window.innerHeight - 20;
		
		if(maxWidth > this.originalWidth){
			maxWidth = this.originalWidth;
		}
		if(maxHeight > this.originalHeight){
			maxHeight = this.originalHeight;
		}

		var newWidth = maxWidth;
		var newHeight = Math.floor(this.originalHeight * (newWidth / this.originalWidth));
		
		if(newHeight > maxHeight){
			newHeight = maxHeight;
			newWidth = Math.floor(this.originalWidth * (newHeight / this.originalHeight));
		}
		
		this.width = newWidth;
		this.height = newHeight;
	});
}

window.addToReply = function(string) {
	jQuery('#reply-body').val(jQuery('#reply-body').val() + string);
};

// Post quoting
window.quotePost = function(postId){
	var postDiv = '#post-'+postId;
	if($(postDiv).length > 0) {
		var permalink = jQuery(postDiv+' .post_info .permalink a').get()[0].href.replace(/^https?:\/\/([\w\d\.:\-]*)/,'');
		var username  = jQuery(postDiv+' .post_info .username a').text();
		var content   = jQuery(postDiv+' .body').html().replace(/^[\s]*/, '').replace(/[\s]*$/, '').replace(/<br[\s\/]*>/g, "\n");
		var quotedPost = '<blockquote><cite>Posted by <a href="'+permalink+'">'+username+'</a>:</cite>'+content+'</blockquote>';
		window.addToReply(quotedPost);
	}
};

var currentWidth = 0;
var currentHeight = 0;
function checkWindowOrientation() {
	if (window.innerWidth != currentWidth) {   
		currentWidth  = window.innerWidth;
		currentHeight = window.innerHeight;
		var orient = (currentWidth < currentHeight) ? 'profile' : 'landscape';
		document.body.setAttribute("orient", orient);
		resizeYoutube();
	}
}
setTimeout(checkWindowOrientation, 0);
checkTimer = setInterval(checkWindowOrientation, 300);

function hideImagesInPosts() {
	// Hide images in posts by default
	$('.post .body img').each(function() {
		this.originalSrc = this.src;
		this.linkTarget = this.src;
		this.removeAttribute("height");
		if(this.parentNode.tagName == "A") {
			this.linkTarget = this.parentNode.href;
			$(this.parentNode).replaceWith(this);
		}
	});
	$('.post .body img').wrap('<div class="imageloader"></div>');
	$('.post .body img').each(function(){
		this.parentNode.image = this;
		this.parentNode.originalSrc = this.src;
		this.src = "/images/blank.gif";
		$(this).click(function(){
			window.location = this.linkTarget;
		});
	});
	$('.post .body .imageloader').click(function(){
		$(this).removeClass('imageloader');
		this.image.src = this.image.originalSrc;
	});
	
}

$(document).ready(function(){

	// Larger click targets on discussion overview
	$('.discussions .discussion h2 a').each(function(){
		var url = this.href;
		$(this.parentNode.parentNode).click(function(){
			document.location = url;
		});
	});

	if (document.location.toString().match(/\#/)) {
		setTimeout(function(){
			var anchorName = document.location.toString().match(/\#([\w\d\-_]+)/)[1];
			var scrollPosition = $("#"+anchorName).offset().top;
			scrollTo(0, scrollPosition);
		}, 1000);
	} else {
		// Scroll to top w/o location bar unless targeting an anchor
		setTimeout(scrollTo, 100, 0, 1);
	}
	
	jQuery('#search_mode').change(function(){
		this.parentNode.action = this.value;
	});
	
	// Post quoting
	$('.post .functions a.quote_post').click(function(){
		var postId = this.id.match(/-([\d]+)$/)[1];
		window.quotePost(postId);
		return false;
	});
	
	// Spoiler tags
	$('.spoiler').each(function(){
		var container = this;
		if(!container.spoilerApplied) {
			if($(container).find('.innerSpoiler').length < 1){
				$(container).wrapInner('<span class="innerSpoiler"></span>');
			}
			if($(container).find('.spoilerLabel').length < 1){
				$(container).prepend('<span class="spoilerLabel">Spoiler!</span> ');
			}
			$(container).find('.innerSpoiler').hide();
			$(container).click(function(){
				$(container).find('.innerSpoiler').show();
				$(container).find('.spoilerLabel').hide();
			});
			container.spoilerApplied = true;
		}
	});
	

	resizeYoutube();
});
