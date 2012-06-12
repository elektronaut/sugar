$(Sugar).bind 'ready', ->

	$buttons = $('#button-container')

	show_status = (message) ->
		$buttons.find('.status').html(message)
		$buttons.find('button').hide()
		$buttons.addClass('posting')

	clear_status = ->
		$buttons.find('.status').html('')
		$buttons.find('button').fadeIn('fast')
		$buttons.removeClass('posting')
		if $(".posts #previewPost").length > 0
			$buttons.find('.preview span').html('Update Preview')
		else
			$buttons.find('.preview span').html('Preview')

	$(Sugar).bind 'posting-status', (event, message) ->
		show_status message

	$(Sugar).bind 'posting-complete', ->
		clear_status()