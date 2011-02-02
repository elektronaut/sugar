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
		var facebook_lib = this;
		this.appId = Sugar.Configuration.FacebookAppId;

		// Listens for a ready event on the Facebook object, which will be triggered
		// when everything is done loading.
		$(this).bind('ready', function () {
			this.applyFunctionality();
		});

		// Sets up the initialize function which Facebook calls when the script is embedded.
		window.fbAsyncInit = function () {

			// Let's get started.
			FB.init({
				appId  : Sugar.Facebook.appId,
				status : true, // check login status
				cookie : true, // enable cookies to allow the server to access the session
				xfbml  : true  // parse XFBML
			});

			// Subscribe to the auth.sessionChange event, which is called whenever the
			// state over at Facebook changes.
			FB.Event.subscribe('auth.sessionChange', function (response) {

				// Let's emit some nice jQuery events so we won't have to deal
				// with the Facebook API directly. 
				$(facebook_lib).trigger('auth.sessionChange');
				if (response.session) {
					$(facebook_lib).trigger('auth.login');
				} else {
					$(facebook_lib).trigger('auth.logout');
				}
			});
			
			// That's it, we're ready.
			$(facebook_lib).trigger('ready');
		};

		// All the callbacks have been set up, let's embed the Facebook scripts.
		$('body').append('<div id="fb-root" />');
		var e = document.createElement('script');
		e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
		e.async = true;
		document.getElementById('fb-root').appendChild(e);
	},

	// Checks Facebook login status and redirects to the specified URL if there is a session. 
	// If we don't have a Facebook session, a login is prompted, optionally asking for permissions.
	// If the login succeeds, the redirect is performed. 
	loginAndRedirect: function (redirectUrl) {
		FB.getLoginStatus(function (response) {
			if (response.session) {
				document.location = redirectUrl;
			} else {
				FB.login(function (response) {
					if (response.session) {
						document.location = redirectUrl;
					}
				}, {perms: 'user_likes,read_friendlists,offline_access'});
			}
		});
	},

	applyFunctionality: function () {

		// Add some stuff to the login buttons so that Facebook can format it properly. 
		$('.facebook_login').addClass('fb_button fb_button_large').wrapInner('<span class="fb_button_text" />');

		// This is the button on the login screen, which should just redirect to the root path
		// if we can get a Facebook session. The backend handles the rest.
		$('#login .facebook_login').click(function () {
			Sugar.Facebook.loginAndRedirect('/?fb_login=1');
			return false;
		});
		
		// This is the button that will let you connect your Facebook account while
		// editing your profile.
		$('.edit_user_profile .facebook_login').click(function () {
			Sugar.Facebook.loginAndRedirect('/users/connect_facebook');
			return false;
		});

		// Handles signing up via Facebook. This can be done in a few ways,
		// so let's wrap it up in a function.
		var doSignup = function () {
			$('#facebook .signup').hide();
			FB.getLoginStatus(function (response) {
				if (response.session) {
					$('#facebook .connect').hide();
					$('#facebook .signup').show();
					FB.api('/me', function (response) {
						$('#facebook .login_status').html('You are logged into Facebook as <strong>' + response.name + '</strong>.');
						if (!$('#facebook #user_username').val()) {
							$('#facebook #user_username').val(response.name);
						}
						if (!$('#facebook #user_realname').val()) {
							$('#facebook #user_realname').val(response.name);
						}
					});
				}
			});
		};

		// Perform signup if .signup #facebook exists in the DOM.
		$('.signup #facebook').each(function () {
			doSignup();
		});

		// This is the Facebook login button on the signup form. Clicking it
		// asks for email in addition to the regular permissions, which is nice
		// to have when creating a new user.
		$('.signup .facebook_login').click(function () {
			FB.getLoginStatus(function (response) {
				if (response.session) {
					doSignup();
				} else {
					FB.login(function (response) {
						if (response.session) {
							doSignup();
						}
					}, {perms: 'email,user_likes,read_friendlists,offline_access'});
				}
			});
			return false;
		});
	}
};
