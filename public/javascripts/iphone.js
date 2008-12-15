Event.observe(window, 'load', function() { 

	// Scroll to top w/o location bar unless targeting an anchor
	if ( !document.location.toString().match(/\#/) ) {
		setTimeout(scrollTo, 100, 0, 1);
	}
	
	// Make the search mode selection box work
	Event.observe($('search_mode_posts'), 'change', function(e) {
		Event.element(e).parentNode.action = Event.element(e).value;
	});
	Event.observe($('search_mode_titles'), 'change', function(e) {
		Event.element(e).parentNode.action = Event.element(e).value;
	});

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

function toggleNavigation() {
	//Effect.toggle('navigation', 'slide', { duration: 0.2, scaleContent: false });
	Element.toggle('navigation');
}