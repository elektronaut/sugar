$(Sugar).bind 'ready', ->

  # Checkbox logic
  $('.edit_user_profile').each ->

    checkTrusted = ->
      if $('#user_user_admin:checked').val() || $('#user_moderator:checked').val()
        $('#user_trusted').attr('checked', true)
        $('#user_trusted').attr('disabled', true)
      else
        $('#user_trusted').attr('disabled', false)

    checkAdmin = ->
      if $('#user_admin:checked').val()
        $('#user_moderator').attr('checked', true).attr('disabled', true)
        $('#user_user_admin').attr('checked', true).attr('disabled', true)
      else
        $('#user_moderator').attr('disabled', false)
        $('#user_user_admin').attr('disabled', false)

    $('#user_moderator, #user_user_admin').click(checkTrusted)
    $('#user_admin').click(checkAdmin).click(checkTrusted)

    checkAdmin();
    checkTrusted();

  # Location map
  $("#editProfileMap").each ->
    defaultLocation = new google.maps.LatLng(46.073231, -32.343750)
    defaultZoom     = 2
    hasLocation     = false
    userLocation    = false
    geocoder        = new google.maps.Geocoder()
    userMarker      = false

    mapOptions =
      center:         defaultLocation
      zoom:           defaultZoom
      mapTypeId:      google.maps.MapTypeId.ROADMAP
      mapTypeControl: false

    if $("#user_latitude").val() and $("#user_latitude").val()
      hasLocation       = true
      userLocation      = new google.maps.LatLng($("#user_latitude").val(), $("#user_longitude").val())
      mapOptions.center = userLocation
      mapOptions.zoom   = 10

    map = new google.maps.Map(this, mapOptions)

    updatePosition = (latlng) ->
      $("#user_latitude").val latlng.lat()
      $("#user_longitude").val latlng.lng()
      if geocoder
        geocoder.geocode
          latLng: latlng
        , (results, status) ->
          if status is google.maps.GeocoderStatus.OK
            if results[0]
              locationString = []
              a = 0

              while a < results[0].address_components.length
                component = results[0].address_components[a]
                validComponent = false
                validComponents = [ "administrative_area_level_2", "administrative_area_level_1", "country", "locality" ]
                t = 0

                while t < component.types.length
                  validComponent = true  if $.inArray(component.types[t], validComponents) > -1
                  t += 1
                if validComponent and $.inArray(component.long_name, locationString) is -1
                  locationString[locationString.length] = component.long_name
                a += 1
              $("#user_location").val locationString.join(", ")


    createUserMarker = (position) ->
      if userMarker
        userMarker.setVisible true
        userMarker.setPosition position
      else
        userMarker = new google.maps.Marker(
          position: position
          map: map
          draggable: true
          visible: true
        )
        google.maps.event.addListener userMarker, "click", ->
          map.setCenter userMarker.position

        google.maps.event.addListener userMarker, "dragend", ->
          map.setCenter userMarker.position
          updatePosition userMarker.position

    window.clearLocation = ->
      hasLocation = false
      $("#user_latitude").val ""
      $("#user_longitude").val ""
      $("#user_location").val ""
      userMarker.setVisible false  if userMarker
      map.setZoom defaultZoom
      map.setCenter defaultLocation

    createUserMarker userLocation  if userLocation
    google.maps.event.addListener map, "click", (args) ->
      position = args.latLng
      unless hasLocation
        updatePosition position
        createUserMarker position
        map.setCenter position
        map.setZoom 6  if map.getZoom() <= 4
        hasLocation = true
