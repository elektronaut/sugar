# encoding: utf-8

class PostObserver < ActiveRecord::Observer
  observe Post

  def clean_cache_for(post)
    exchange_type = post.conversation ? "conversation" : "discussion"
    cache_file = Rails.root.join(
      "public/cache/#{exchange_type}s/#{post.exchange_id}/posts/count.json"
    )
    File.unlink(cache_file) if File.exist?(cache_file)
  end

  def after_create(post)
    clean_cache_for(post)
  end

  def after_destroy(post)
    clean_cache_for(post)
  end
end
