function toggleNavigation() {
	$('#navigation').toggle();
}

var currentWidth = 0;
function checkWindowOrientation() {
	if (window.innerWidth != currentWidth) {   
		currentWidth = window.innerWidth;
		var orient = currentWidth == 320 ? "profile" : "landscape";
		document.body.setAttribute("orient", orient);
	}
}
setTimeout(checkWindowOrientation, 0);
checkTimer = setInterval(checkWindowOrientation, 300);

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

	// Hide images in posts by default
	$('.post .body img').each(function(){
		this.originalSrc = this.src;
		this.linkTarget  = this.src;
		this.src         = '/themes/default-iphone/images/imageloader.gif';
		this.removeAttribute("height");
		
		if(this.parentNode.tagName == "A") {
			this.linkTarget = this.parentNode.href;
			$(this.parentNode).replaceWith(this);
		}
		
		$(this).click(function(){
			if(this.src != this.originalSrc){
				this.src = this.originalSrc;
			} else {
				window.location = this.linkTarget;
			}
		});
	});
	

});
