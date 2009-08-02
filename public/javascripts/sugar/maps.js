$.extend(Sugar.Initializers, {

	usersMap : function() {
		$('#usersMap').each(function(){
			var map = new GMap2(this);
			var defaultLocation = new GLatLng(46.073231,-32.343750);
			map.addControl(new GLargeMapControl());
			map.addControl(new GMapTypeControl());
			map.setCenter(defaultLocation, 3);

			var usersAPIurl = '/users.json';
				$.getJSON(usersAPIurl, function(json) {
					$(json).each(function(){
						var user = this.user;
						if(user.latitude && user.longitude) {
							var position = new GLatLng(user.latitude, user.longitude);
							var marker = new GMarker(position);
							GEvent.addListener(marker, "click", function() {
								marker.openInfoWindowHtml(
									"<strong>"+user.username+"</strong><br />" +
									((user.realname) ? user.realname+"<br />" : "") +
									"<a href=\"/users/profile/"+user.username+"\">View profile</a>");
							});
							map.addOverlay(marker);
						}
					});
				});
			});
	},

	editProfileMap : function() {
		$('#editProfileMap').each(function(){

			var map = new GMap2(this);
			var defaultLocation = new GLatLng(46.073231,-32.343750);
			map.addControl(new GLargeMapControl());
			map.addControl(new GMapTypeControl());

			var updatePosition = function(latlng){
				$('#user_latitude').val(latlng.lat());
				$('#user_longitude').val(latlng.lng());
			};

			var userMarker = false;
			var createUserMarker = function(latlng){
				userMarker = new GMarker(latlng, {draggable:true});
				map.addOverlay(userMarker);
				GEvent.addListener(userMarker, "click", function() {
					map.setCenter(userMarker.getLatLng());
				});
				GEvent.addListener(userMarker, "dragend", function() {
					updatePosition(userMarker.getLatLng());
				});
			};

			window.clearLocation = function(){
				$('#user_latitude').val('');
				$('#user_longitude').val('');
				map.removeOverlay(userMarker);
				userMarker = false;
			};


			if(!$('#user_latitude').val() || !$('#user_latitude').val()) {
				map.setCenter(defaultLocation, 2);
			} else {
				var location = new GLatLng($('#user_latitude').val(), $('#user_longitude').val());
				map.setCenter(location, 10);
				createUserMarker(location);
			}

			GEvent.addListener(map, "click", function(overlay, latlng) {
				if(!userMarker) {
					updatePosition(latlng);
					createUserMarker(latlng);
				}
			});
		});
	}

});