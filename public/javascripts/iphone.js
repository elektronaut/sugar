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

var currentWidth = 0;
function checkWindowOrientation() {
	if (window.innerWidth != currentWidth) {   
		currentWidth = window.innerWidth;
		var orient = currentWidth == 320 ? "profile" : "landscape";
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

	// Scroll to top w/o location bar unless targeting an anchor
	if ( !document.location.toString().match(/\#/) ) {
		setTimeout(scrollTo, 100, 0, 1);
	}
	
	jQuery('#search_mode_posts').change(function(){
		this.parentNode.action = this.value;
	});
	jQuery('#search_mode_titles').change(function(){
		this.parentNode.action = this.value;
	});

	resizeYoutube();
});
