(function ($S) {

  $($S).bind('ready', function () {
    this.Maps.editProfile('#editProfileMap');
  });

  $S.Maps = {

    // Edit profile map
    editProfile: function (selector) {
      $(selector).each(function () {
        var defaultLocation = new google.maps.LatLng(46.073231, -32.343750);
        var defaultZoom     = 2;
        var hasLocation     = false;
        var userLocation    = false;
        var geocoder        = new google.maps.Geocoder();

        var mapOptions = {
          center:         defaultLocation,
          zoom:           defaultZoom,
          mapTypeId:      google.maps.MapTypeId.ROADMAP,
          mapTypeControl: false
        };

        if ($('#user_latitude').val() && $('#user_latitude').val()) {
          hasLocation = true;
          userLocation  = new google.maps.LatLng($('#user_latitude').val(), $('#user_longitude').val());
          mapOptions.center = userLocation;
          mapOptions.zoom   = 10;
        }

        var map = new google.maps.Map(this, mapOptions);

        var updatePosition = function (latlng) {
          $('#user_latitude').val(latlng.lat());
          $('#user_longitude').val(latlng.lng());
          // Reverse geocode the location
          if (geocoder) {
            geocoder.geocode({'latLng': latlng}, function (results, status) {
              if (status === google.maps.GeocoderStatus.OK) {
                if (results[0]) {
                  var locationString = [];
                  for (var a = 0; a < results[0].address_components.length; a += 1) {
                    var component = results[0].address_components[a];
                    var validComponent = false;
                    var validComponents = ['administrative_area_level_2', 'administrative_area_level_1', 'country', 'locality'];
                    for (var t = 0; t < component.types.length; t += 1) {
                      if ($.inArray(component.types[t], validComponents) > -1) {
                        validComponent = true;
                      }
                    }
                    if (validComponent && $.inArray(component.long_name, locationString) === -1) {
                      locationString[locationString.length] = component.long_name;
                    }
                  }
                  $('#user_location').val(locationString.join(', '));
                }
              }
            });
          }
        };

        var userMarker = false;

        var createUserMarker = function (position) {
          if (userMarker) {
            userMarker.setVisible(true);
            userMarker.setPosition(position);
          } else {
            userMarker = new google.maps.Marker({
              position:  position,
              map:       map,
              draggable: true,
              visible:   true
            });
            google.maps.event.addListener(userMarker, 'click', function () {
              map.setCenter(userMarker.position);
            });
            google.maps.event.addListener(userMarker, 'dragend', function () {
              map.setCenter(userMarker.position);
              updatePosition(userMarker.position);
            });
          }
        };

        window.clearLocation = function () {
          hasLocation = false;
          $('#user_latitude').val('');
          $('#user_longitude').val('');
          $('#user_location').val('');
          if (userMarker) {
            userMarker.setVisible(false);
          }
          map.setZoom(defaultZoom);
          map.setCenter(defaultLocation);
        };

        if (userLocation) {
          createUserMarker(userLocation);
        }

        google.maps.event.addListener(map, 'click', function (args) {
          var position = args.latLng;
          if (!hasLocation) {
            updatePosition(position);
            createUserMarker(position);
            map.setCenter(position);
            if (map.getZoom() <= 4) {
              map.setZoom(6);
            }
            hasLocation = true;
          }
          /*
          if (!userMarker || !userMarker.getVisible()) {
            updatePosition(position);
            createUserMarker(position);
          }
          */
        });

      });
    }
  };

})(Sugar);