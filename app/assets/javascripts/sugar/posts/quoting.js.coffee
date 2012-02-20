Sugar.extend

  quotePost: (post) ->

    $(post).each ->

      if window.getSelection? and window.getSelection().containsNode(this, true)
        content = window.getSelection().toString()

      unless content
        content = $(this).find('.body .content').html()
          .replace(/^[\s]*/, '')          # Strip leading space
          .replace(/[\s]*$/, '')          # Strip trailing space
          .replace(/<br[\s\/]*>/g, "\n"); # Change <br /> to line breaks

      if $(this).hasClass('me_post')
        username  = $(this).find('.body .poster').text()
        quotedPost = '<blockquote><cite>Posted by ' + username + ':</cite>' + content + '</blockquote>'

      else
        permalink = $(this).find('.post_info .permalink a').get()[0].href.replace(/^https?:\/\/([\w\d\.:\-]*)/, '')
        username  = $(this).find('.post_info .username a').text()
        quotedPost = '<blockquote><cite>Posted by <a href="' + permalink + '">' + username + '</a>:</cite>' + content + '</blockquote>'

        # Trim empty blockquotes
        while quotedPost.match(/<blockquote>[\s]*<\/blockquote>/)
          quotedPost = quotedPost.replace(/<blockquote>[\s]*<\/blockquote>/, '')

      Sugar.compose({add: quotedPost})

$(Sugar).bind 'ready postsloaded', ->

  $('.quote_post').each ->
    unless this.functionalityApplied
      this.functionalityApplied = true
      $(this).click ->
        Sugar.quotePost($(this).closest('.post'))
        return false
