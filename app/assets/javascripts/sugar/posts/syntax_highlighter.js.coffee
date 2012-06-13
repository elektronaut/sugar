$(Sugar).bind 'ready postsloaded', ->

  # Transform the code blocks to work with SyntaxHighlighter
  $('pre.code code').each ->
    parent = $(this).closest('pre').get(0)
    language = this.className
    $(parent).html($(this).html())
    parent.className = parent.className + ' brush: ' + language
    $(parent).closest('.body').addClass('syntax')

  SyntaxHighlighter.all();
