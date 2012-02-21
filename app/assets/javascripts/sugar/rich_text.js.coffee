$(Sugar).bind 'ready modified', ->
  $('textarea.rich').each ->

    unless this.toolbar
      ta = new JRichTextArea(this)

      # Setup the buttons
      ta.toolbar

        # Bold
        .addButton "Bold", ->
          this.textArea.wrapSelection('<strong>', '</strong>')

        # Italic
        .addButton "Italics", ->
          this.textArea.wrapSelection('<em>', '</em>')

        # Link
        .addButton "Link", ->
          selection = this.textArea.selectedText()
          response = prompt('Enter link URL', '')
          this.textArea.replaceSelection(
            '<a href="' + (response || 'http://link_url/').replace(/^(?!(f|ht)tps?:\/\/)/, 'http://') + '">' +
            (selection || "Link text") + '</a>'
          )

        # Image tag
        .addButton "Image", ->
          selection = this.textArea.selectedText()
          if selection == ''
            response = prompt('Enter image URL', '')
            unless response
              return
            this.textArea.replaceSelection('<img src="' + response + '" alt="" />')
          else
            this.textArea.replaceSelection('<img src="' + selection + '" alt="" />')

        # MP3 Player
        .addButton "MP3", ->
          selection = this.textArea.selectedText()
          response = prompt('Enter MP3 URL', '')
          unless selection
            selection = prompt('Enter track title', '')
          this.textArea.replaceSelection(
            '<a href="' + (response || 'http://link_url/').replace(/^(?!(f|ht)tps?:\/\/)/, 'http://') + '" class="mp3player">' +
            (selection || "Link text") + '</a>')

        # Block Quote
        .addButton "Block Quote", ->
          this.textArea.wrapSelection('<blockquote>', '</blockquote>')

        # Escape HTML
        .addButton "Escape HTML", ->
          selection = this.textArea.selectedText()
          response = prompt('Enter language (leave blank for no syntax highlighting)', '')
          if response
            this.textArea.replaceSelection('<code language="' + response + '">' + selection + '</code>')
          else
            this.textArea.replaceSelection('<code>' + selection + '</code>')

        # Spoiler
        .addButton "Spoiler", ->
          this.textArea.wrapSelection('<div class="spoiler">', '</div>')
