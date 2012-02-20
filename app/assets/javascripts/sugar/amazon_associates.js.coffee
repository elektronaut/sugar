$ ->
	if referral_id = Sugar.Configuration.AmazonAssociatesId

		apply_referral_links = ->
			$('.post .body a').each ->
				link = this
				if !$.data(link, 'amazon_associates_referral_id') && link.href.match /https?:\/\/([\w\d\-\.])*amazon\.com/
					$.data(link, 'amazon_associates_referral_id', referral_id)
					return if link.href.match /(\?|&)tag=/

					link.href += if link.href.match(/\?/) then '&' else '?'
					link.href += 'tag=' + referral_id
			
		$(Sugar).bind('postsloaded', apply_referral_links)
		apply_referral_links()
