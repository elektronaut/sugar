$(Sugar).bind('ready', function() {
  $('.edit_user_profile').each(function() {
    let checkTrusted = function() {
      let alwaysTrusted = $('#user_user_admin:checked').val() ||
                          $('#user_moderator:checked').val();
      if (alwaysTrusted) {
        $('#user_trusted').attr('checked', true);
        $('#user_trusted').attr('disabled', true);
      } else {
        $('#user_trusted').attr('disabled', false);
      }
    };

    let checkAdmin = function() {
      if ($('#user_admin:checked').val()) {
        $('#user_moderator').attr('checked', true).attr('disabled', true);
        $('#user_user_admin').attr('checked', true).attr('disabled', true);
      } else {
        $('#user_moderator').attr('disabled', false);
        return $('#user_user_admin').attr('disabled', false);
      }
    };

    $('#user_moderator, #user_user_admin').click(checkTrusted);
    $('#user_admin').click(checkAdmin).click(checkTrusted);
    $(this).find('.clear-location').click(function() {
      window.clearLocation();
      return false;
    });
    checkAdmin();
    checkTrusted();
  });

  $("#editProfileMap").each(function() {
    let defaultLocation = new google.maps.LatLng(46.073231, -32.343750);
    let defaultZoom = 2;
    let geocoder = new google.maps.Geocoder();

    var hasLocation = false;
    var userLocation = false;
    var userMarker = false;
    var mapOptions = {
      center: defaultLocation,
      zoom: defaultZoom,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      mapTypeControl: false
    };

    if ($("#user_latitude").val() && $("#user_latitude").val()) {
      hasLocation = true;
      userLocation = new google.maps.LatLng(
        $("#user_latitude").val(),
        $("#user_longitude").val()
      );
      mapOptions.center = userLocation;
      mapOptions.zoom = 10;
    }

    let map = new google.maps.Map(this, mapOptions);

    let updatePosition = function (latlng) {
      $("#user_latitude").val(latlng.lat());
      $("#user_longitude").val(latlng.lng());
      if (geocoder) {
        let validComponents = [
          "administrative_area_level_2",
          "administrative_area_level_1",
          "country",
          "locality"
        ];
        geocoder.geocode({ latLng: latlng }, function (results, status) {
          var component, locationString, validComponent;
          var component, validComponent;
          if (status === google.maps.GeocoderStatus.OK) {
            if (results[0]) {
              var locationString = [];
              for (var a = 0; a < results[0].address_components.length; a++) {
                component = results[0].address_components[a];
                validComponent = false;
                for (var t = 0; t < component.types.length; t++) {
                  if ($.inArray(component.types[t], validComponents) > -1) {
                    validComponent = true;
                  }
                }
                if (validComponent &&
                    $.inArray(component.long_name, locationString) === -1) {
                  locationString.push(component.long_name);
                }
              }
              $("#user_location").val(locationString.join(", "));
            }
          }
        });
      }
    };

    let createUserMarker = function (position) {
      if (userMarker) {
        userMarker.setVisible(true);
        return userMarker.setPosition(position);
      } else {
        userMarker = new google.maps.Marker({
          position: position,
          map: map,
          draggable: true,
          visible: true
        });
        google.maps.event.addListener(userMarker, "click", function() {
          map.setCenter(userMarker.position);
        });
        google.maps.event.addListener(userMarker, "dragend", function() {
          map.setCenter(userMarker.position);
          updatePosition(userMarker.position);
        });
      }
    };

    window.clearLocation = function() {
      hasLocation = false;
      $("#user_latitude").val("");
      $("#user_longitude").val("");
      $("#user_location").val("");
      if (userMarker) {
        userMarker.setVisible(false);
      }
      map.setZoom(defaultZoom);
      map.setCenter(defaultLocation);
    };

    if (userLocation) {
      createUserMarker(userLocation);
    }

    google.maps.event.addListener(map, "click", function(args) {
      let position = args.latLng;
      if (!hasLocation) {
        updatePosition(position);
        createUserMarker(position);
        map.setCenter(position);
        if (map.getZoom() <= 4) {
          map.setZoom(6);
        }
        return hasLocation = true;
      }
    });
  });
});
