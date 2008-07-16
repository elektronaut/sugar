Event.observe(window, 'load', function() { 

	// Scroll to top w/o location bar unless targeting an anchor
	if ( !document.location.toString().match(/\#/) ) {
		setTimeout(scrollTo, 100, 0, 1);
	}
	

});

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

