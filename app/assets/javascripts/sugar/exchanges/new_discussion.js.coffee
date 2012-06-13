$(Sugar).bind 'ready', ->

  # Suggest similar discussions
  $("#new_discussion").each ->
    title = $(this).find(".title").get(0)
    $(title).after "<div class=\"title_search\"></div>"
    searchResults = $(this).find(".title_search").get(0)
    $(searchResults).hide()
    $(title).keydown (event) ->
      setTimeout (->
        if $(title).val() and title.previousValue isnt $(title).val()
          title.previousValue = $(title).val()
          $(searchResults).addClass("loading").html("Searching for similar discussions...").show()
          clearInterval title.keypressInterval  if title.keypressInterval
          title.keypressInterval = setInterval(->
            words = $(title).val().toLowerCase().split(/\s+/)
            words = $.grep(words, (word) ->
              $.inArray(word, Sugar.stopwords) < 0
            )
            words = $.map(words, (word) ->
              word.replace /[!~\^=\$\*\[\]\{\}]/, ""
            )
            words[words.length - 1] += "*"  if words[words.length - 1].match(/^[\w]{3}[^\*]*$/)
            query = words.join(" | ")
            $.getJSON "/discussions/search.json",
              query: query
            , (json) ->
              Sugar.log "New discussion: Loaded " + json.discussions.length + " of " + json.total_entries + " search results for \"" + query + "\""
              $(searchResults).removeClass "loading"
              if json.discussions.length > 0
                output = "<h4>Similar discussions found. Maybe you should check them out before posting?</h4>"
                discussion = null
                a = 0

                while a < 10
                  if a < json.discussions.length
                    discussion = json.discussions[a].discussion
                    output += "<a href=\"/discussions/" + discussion.id + "\" class=\"discussion\">" + discussion.title + " <span class=\"posts_count\">" + discussion.posts_count + " posts</span></a>"
                  a += 1
                output += "<a href=\"/search?q=" + encodeURIComponent(query) + "\">Show all " + (json.total_entries) + " results</a>"  if json.total_entries > 10
                $(searchResults).html(output).hide().slideDown "fast"
              else
                $(searchResults).html("").hide()

            clearInterval title.keypressInterval
          , 500)
      ), 10
