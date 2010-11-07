class PostObserver < ActiveRecord::Observer
	observe Post

	def clean_cache_for(record)
		# Clean posts count cache
		cache_file = Rails.root.join("public/cache/discussions/#{record.discussion_id}/posts/count.js")
		if File.exists?(cache_file)
			File.unlink(cache_file)
		end
	end

	def after_create(record)
		clean_cache_for(record)
	end
	def after_update(record)
		#clean_cache_for(record)
	end
	def after_destroy(record)
		#clean_cache_for(record)
	end

end
