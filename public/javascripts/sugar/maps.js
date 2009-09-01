$.extend(Sugar.Initializers, {

	usersMap : function() {
		$('#usersMap').each(function(){
			var defaultLocation = new google.maps.LatLng(30,-20);
			var map = new google.maps.Map(this, {
				center: defaultLocation, 
				zoom: 2,
				mapTypeId: google.maps.MapTypeId.ROADMAP
			});

			var usersAPIurl = '/users.json';
			$.getJSON(usersAPIurl, function(json) {
				$(json).each(function(){
					var user = this.user;
					if(user.latitude && user.longitude) {
						var position = new google.maps.LatLng(user.latitude, user.longitude);
						var marker = new google.maps.Marker({
							position: position, map: map, title: user.username
						});
						var contentString = "<strong>"+user.username+"</strong><br />" +
							((user.realname) ? user.realname+"<br />" : "") +
							"<a href=\"/users/profile/"+user.username+"\">View profile</a>";
						var infowindow = new google.maps.InfoWindow({content: contentString});
						google.maps.event.addListener(marker, 'click', function() {
							infowindow.open(map,marker);
						});
					}
				});
			});

		});
	},

	editProfileMap : function() {
		$('#editProfileMap').each(function(){
			var defaultLocation = new google.maps.LatLng(46.073231,-32.343750);

			var mapOptions = {
				center: defaultLocation, 
				zoom: 2,
				mapTypeId: google.maps.MapTypeId.ROADMAP,
				mapTypeControl: false
			};

			if($('#user_latitude').val() && $('#user_latitude').val()) {
				var userLocation = new google.maps.LatLng($('#user_latitude').val(), $('#user_longitude').val());
				mapOptions.center = userLocation;
				mapOptions.zoom = 10;
			}

			var map = new google.maps.Map(this, mapOptions);

			var updatePosition = function(latlng){
				$('#user_latitude').val(latlng.lat());
				$('#user_longitude').val(latlng.lng());
			};
			
			var userNarker = false;

			var createUserMarker = function(position){
				if(userNarker){
					userMarker.set_visible(true);
					userMarker.set_position(position);
				} else {
					userMarker = new google.maps.Marker({
						position: position, map: map, draggable: true, visible: true
					});
					google.maps.event.addListener(userMarker, 'click', function() {
						map.set_center(userMarker.position);
					});
					google.maps.event.addListener(userMarker, 'dragend', function() {
						updatePosition(userMarker.position);
					});
				}
			};

			window.clearLocation = function(){
				$('#user_latitude').val('');
				$('#user_longitude').val('');
				userMarker.set_visible(false);
			};

			if(userLocation) {
				createUserMarker(userLocation);
			}

			google.maps.event.addListener(map, 'click', function(args) {
				var position = args.latLng;
				if(!userMarker || !userMarker.get_visible()){
					updatePosition(position);
					createUserMarker(position);
				}
			});

		});
	}

});