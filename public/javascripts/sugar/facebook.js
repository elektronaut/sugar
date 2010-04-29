(function($S){
	
	$($S).bind('ready', function(){
		if(this.Configuration.FacebookAppId){
			this.Facebook.init();
		}
	});
	
	$S.Facebook = {
		appId: false,
		init: function(){
			var facebook_lib = this;
			this.appId = $S.Configuration.FacebookAppId;

			$(this).bind('ready', function(){
				this.applyFunctionality();
			});

			// Connect to Facebook asynchronously, jQuery style
			$('body').append('<div id="fb-root" />');
			window.fbAsyncInit = function() {
				// Initialize Facebook
				FB.init({
					appId  : $S.Facebook.appId,
					status : true, // check login status
					cookie : true, // enable cookies to allow the server to access the session
					xfbml  : true  // parse XFBML
				});
				// Bind events
				FB.Event.subscribe('auth.sessionChange', function(response) {
					$(facebook_lib).trigger('auth.sessionChange');
					if(response.session){
						$(facebook_lib).trigger('auth.login');
					} else {
						$(facebook_lib).trigger('auth.logout');
					}
				});
				$(facebook_lib).trigger('ready');
			};
			var e = document.createElement('script');
			e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
			e.async = true;
			document.getElementById('fb-root').appendChild(e);
		},

		applyFunctionality: function(){
			// Format buttons
			$('.facebook_login').addClass('fb_button fb_button_large').wrapInner('<span class="fb_button_text" />');

			// Connect under Services
			$('.edit_user_profile .facebook_login').click(function(){
				$S.Facebook.loginAndRedirect('/users/connect_facebook');
				return false;
			});

			// Login handler
			$('#login .facebook_login').click(function(){
				$S.Facebook.loginAndRedirect('/users/facebook_login');
				return false;
			});
			
			// Signing up
			var doSignup = function(){
				$('#facebook .signup').hide();
				FB.getLoginStatus(function(response){
					if(response.session){
						$('#facebook .connect').hide();
						$('#facebook .signup').show();
						FB.api('/me', function(response){
							$('#facebook .login_status').html('You are logged into Facebook as <strong>'+response.name+'</strong>.');
							if(!$('#facebook #user_username').val()){
								$('#facebook #user_username').val(response.name);
							}
							if(!$('#facebook #user_realname').val()){
								$('#facebook #user_realname').val(response.name);
							}
						});
					}
				});
			};
			$('.signup #facebook').each(function(){
				doSignup();
			});
			$('.signup .facebook_login').click(function(){
				FB.getLoginStatus(function(response){
					if(response.session){
						doSignup();
					} else {
						FB.login(function(response){
							if(response.session){
								doSignup();
							}
						}, {perms:'email,user_likes,read_friendlists,offline_access'});
					}
				});
				return false;
			});
		},
		
		loginAndRedirect: function(redirectUrl){
			FB.getLoginStatus(function(response){
				if(response.session){
					document.location = redirectUrl;
				} else {
					FB.login(function(response){
						if(response.session){
							document.location = redirectUrl;
						}
					}, {perms:'user_likes,read_friendlists,offline_access'});
				}
			});
		}
	};

})(Sugar);