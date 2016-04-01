$(Sugar).bind('ready', function () {
  // Suggest similar discussions
  $("#new_discussion").each(function () {
    var title = $(this).find(".title").get(0);
    $(title).after("<div class=\"title_search\"></div>");
    var searchResults = $(this).find(".title_search").get(0);
    $(searchResults).hide();

    $(title).keydown(function() {
      var searchDiscussions = function() {
        if ($(title).val() && title.previousValue !== $(title).val()) {
          title.previousValue = $(title).val();

          $(searchResults).addClass("loading")
                          .html("Searching for similar discussions...")
                          .show();

          if (title.keypressInterval) {
            clearInterval(title.keypressInterval);
          }

          var keypressFunction = function() {
            var words = $(title).val().toLowerCase().split(/\s+/);

            words = $.grep(words, function(word) {
              return $.inArray(word, Sugar.stopwords) < 0;
            });

            words = $.map(words, function(word) {
              return word.replace(/[!~\^=\$\*\[\]\{\}]/, "");
            });

            let query = words.join(" | ");
            let searchUrl = "/discussions/search.json";

            $.getJSON(searchUrl, { query: query }, function(json) {
              Sugar.log(
                "New discussion: Found " +
                json.discussions.length + " of " + json.meta.total +
                " search results for \"" + query + "\""
              );
              $(searchResults).removeClass("loading");

              if (json.discussions.length > 0) {
                var output = "<h4>Similar discussions found. Maybe you " +
                             "should check them out before posting?</h4>";

                var iterable = json.discussions.slice(0, 10);
                for (var i = 0, discussion; i < iterable.length; i++) {
                  discussion = iterable[i];
                  output += "<a href=\"/discussions/" + discussion.id +
                            "\" class=\"discussion\">" + discussion.title +
                            " <span class=\"posts_count\">" +
                            discussion.posts_count + " posts</span></a>";
                }

                if (json.total_entries > 10) {
                  output += "<a href=\"/search?q=" + encodeURIComponent(query) +
                            "\">Show all " + (json.total_entries) +
                            " results</a>";
                }
                $(searchResults).html(output).hide().slideDown("fast");
              } else {
                $(searchResults).html("").hide();
              }
            });

            clearInterval(title.keypressInterval);
          };
          title.keypressInterval = setInterval(keypressFunction, 500);
        }
      };
      setTimeout(searchDiscussions, 10);
    });
  });
});
