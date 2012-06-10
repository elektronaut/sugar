$(Sugar).bind 'ready postsloaded', ->

  formatDate = (date) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    months[date.getMonth()] + ' ' + date.getDate() + ', ' + date.getFullYear()


  $('time.relative').each ->
    if $(this).attr('datetime')
      date = $.timeago.parse($(this).attr('datetime'))
      delta = ((new Date().getTime() - date.getTime()) / 1000)

      if delta < (14 * 24 * 24 * 60)
        $(this).timeago()
      else
        $(this).html(formatDate(date))