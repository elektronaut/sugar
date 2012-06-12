$(Sugar).bind 'ready', ->

	$container = $('#button-container')

	show_status = (message) ->
		$container.find('.status').html(message)
		$container.find('button').hide()
		$container.addClass('posting')

	clear_status = ->
		$container.find('.status').html('')
		$container.find('button').fadeIn('fast')
		$container.removeClass('posting')

	$(Sugar).bind 'posting-status', (event, message) ->
		show_status message

	$(Sugar).bind 'posting-complete', ->
		clear_status()