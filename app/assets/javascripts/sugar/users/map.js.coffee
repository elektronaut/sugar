$(Sugar).bind 'ready', ->

  $('#usersMap').each ->

    defaultLocation = new google.maps.LatLng(30, -20)

    map = new google.maps.Map this,
      center:    defaultLocation,
      zoom:      2,
      mapTypeId: google.maps.MapTypeId.ROADMAP

    $.getJSON '/users.json', (response) ->
      $(response.users).each ->
        user = this
        if user.latitude && user.longitude
          marker = new google.maps.Marker
            position: new google.maps.LatLng user.latitude, user.longitude
            map:      map
            title:    user.username

          contentString = "<strong>" + user.username + "</strong><br />" +
            ((user.realname) ? user.realname + "<br />" : "") +
            "<a href=\"/users/profile/" + user.username + "\">View profile</a>"

          infowindow = new google.maps.InfoWindow
            content: contentString

          google.maps.event.addListener marker, 'click', ->
            infowindow.open(map, marker);
