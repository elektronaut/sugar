/*jslint browser: true, devel: true, onevar: false, regexp: false, immed: false*/
/*global window: false, jQuery: false, $: false, Sugar: false, FB: false*/

// Listens for a ready event from the framework, trigger init()
// if the application ID is configured.
$(Sugar).bind('ready', function () {
	if (this.Configuration.FacebookAppId) {
		this.Facebook.init();
	}
});

Sugar.Facebook = {

	// The application ID.
	appId: false,

	// Initializer
	init: function () {
		this.appId = Sugar.Configuration.FacebookAppId;

		if ($('.fb_button').length > 0) {
			$('.fb_button').addClass('fb_button_large').wrapInner('<span class="fb_button_text" />');
			this.loadAsync();
		}
	},

	loadAsync: function () {
		var facebook_lib = this;
		$(this).bind('ready', function () {
			// Do stuff when Facebook is ready here
		});

		window.fbAsyncInit = function () {
			FB.init({
				appId  : Sugar.Facebook.appId
				//status : true, // check login status
				//cookie : true, // enable cookies to allow the server to access the session
				//xfbml  : true  // parse XFBML
			});
		};

		// Embed the Facebook script
		$('body').append('<div id="fb-root" />');
		var e = document.createElement('script');
		e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
		e.async = true;
		document.getElementById('fb-root').appendChild(e);
	}
};
