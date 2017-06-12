$(Sugar).bind('ready', function() {
  $('#usersMap').each(function() {
    let defaultLocation = new google.maps.LatLng(30, -20);
    let map = new google.maps.Map(this, {
      center: defaultLocation,
      zoom: 2,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });

    $.getJSON('/users.json', function(response) {
      $(response.users).each(function() {
        let user = this;
        if (user.latitude && user.longitude) {
          let marker = new google.maps.Marker({
            position: new google.maps.LatLng(user.latitude, user.longitude),
            map: map,
            title: user.username
          });
          let contentString = `<strong>${user.username}</strong><br />` +
                              (user.realname ? `${user.realname}<br />` : "") +
                              `<a href="/users/profile/${user.username}">` +
                              `View profile</a>`;
          let infowindow = new google.maps.InfoWindow({
            content: contentString
          });
          google.maps.event.addListener(marker, 'click', function() {
            infowindow.open(map, marker);
          });
        }
      });
    });
  });
});
