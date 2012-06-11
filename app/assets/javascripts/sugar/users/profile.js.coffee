$(Sugar).bind 'ready', ->

  # Show latest tweets
  $("#profileTweets").each ->
    tweetsDiv = this
    username = $(@parentNode).find(".username").get()[0].innerHTML.replace(/^@/, "")
    user_info_url = "http://twitter.com/users/show/" + username + ".json?callback=?"
    updates_url = "http://twitter.com/statuses/user_timeline/" + username + ".json?count=5&callback=?"
    $.getJSON user_info_url, (user_json) ->
      protectedMode = "protected"
      if user_json[protectedMode]
        $(tweetsDiv).html "<p>Updates are protected</p>"
      else
        $.getJSON updates_url, (json) ->
          $(json).each ->
            linkified_text = @text.replace(/[A-Za-z]+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:%&\?\/.=]+/, (m) ->
              m.link m
            )
            linkified_text = linkified_text.replace(/@[A-Za-z0-9_]+/, (u) ->
              u.link "http://twitter.com/" + u.replace(/^@/, "")
            )
            $(tweetsDiv).append "<div class=\"tweet tweet-" + @id + "\">" +
                                "<p class=\"text\">" + linkified_text +
                                " <a href=\"http://twitter.com/" + username +
                                "/statuses/" + @id + "\" class=\"time\">" +
                                relativeTime(@created_at) + "</a>" +
                                "</p>" + "</div>"

  # Show latest photos from Flickr
  if Sugar.Configuration.FlickrAPI
    $("#flickrProfileURL").each ->
      fuid = @href.split("/")
      fuid = fuid[(fuid.length - 1)]
      $("#flickrPhotos").hide()
      $("#flickrPhotos").flickr
        api_key: Sugar.Configuration.FlickrAPI
        type: "search"
        user_id: fuid
        per_page: 15
        callback: (list) ->
          $("#flickrPhotos").show()