$(Sugar).bind 'ready', ->

  relative_time = (timeString) ->
    parsedDate = Date.parse(timeString)
    delta = (Date.parse(Date()) - parsedDate) / 1000
    r = ""
    if delta < 60
      r = "a moment ago"
    else if delta < 120
      r = "a couple of minutes ago"
    else if delta < (45 * 60)
      r = (parseInt(delta / 60, 10)).toString() + " minutes ago"
    else if delta < (90 * 60)
      r = "an hour ago"
    else if delta < (24 * 60 * 60)
      r = "" + (parseInt(delta / 3600, 10)).toString() + " hours ago"
    else if delta < (48 * 60 * 60)
      r = "a day ago"
    else
      r = (parseInt(delta / 86400, 10)).toString() + " days ago"
    r

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
                                relative_time(@created_at) + "</a>" +
                                "</p>" + "</div>"
