$(Sugar).bind('ready postsloaded', function() {
  let formatDate = (date) => {
    let months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[date.getMonth()] + ' ' +
           date.getDate() + ', ' +
           date.getFullYear();
  };

  $('time.relative').each(function() {
    if ($(this).attr('datetime')) {
      let date = $.timeago.parse($(this).attr('datetime'));
      let delta = (new Date().getTime() - date.getTime()) / 1000;
      if (delta < (14 * 24 * 24 * 60)) {
        $(this).timeago();
      } else {
        $(this).html(formatDate(date));
      }
    }
  });
});
