$(Sugar).bind 'ready', ->

  $('body.login #login').each ->
    container = this

    if $.cookie('login_method') == 'openid'
      $(container).find('.username_and_password.form').hide()
    else
      $(container).find('.openid.form').hide()

    $(container).find('.openid_toggle').click ->
      $(container).find('.username_and_password.form').hide()
      $(container).find('.openid.form').show()
      $.cookie 'login_method', 'openid', expires: 365

    $(container).find('.username_and_password_toggle').click ->
      $(container).find('.username_and_password.form').show()
      $(container).find('.openid.form').hide()
      $.cookie 'login_method', null, expires: 365
