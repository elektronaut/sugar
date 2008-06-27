class Post < ActiveRecord::Base

    belongs_to :user, :counter_cache => true
    belongs_to :discussion, :counter_cache => true
    
    validates_presence_of :body
    
    # Automatically update the discussion with last poster info
    after_create do |post|
        post.discussion.update_attributes({:last_poster_id => post.user.id, :last_post_at => post.created_at})
    end
    
    class << self
        def find_paginated(options)
            return []
        end
    end

    def edited?
        (self.created_at <=> self.updated_at) ? true : false
    end
    
end
