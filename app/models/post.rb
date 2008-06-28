class Post < ActiveRecord::Base

    belongs_to :user, :counter_cache => true
    belongs_to :discussion, :counter_cache => true
    
    validates_presence_of :body
    
    # Automatically update the discussion with last poster info
    after_create do |post|
        post.discussion.update_attributes(:last_poster_id => post.user.id, :last_post_at => post.created_at)
    end
    
    class << self

        def find_paginated(options={})
            discussion = options[:discussion]
            posts_count = discussion.posts_count

            # Math is still awesome
            limit = options[:limit] || 50
            num_pages = (posts_count.to_f/limit).ceil
            page  = (options[:page] || 1).to_i
            page = 1 if page < 1
            page = num_pages if page > num_pages
            offset = limit * (page - 1)

            posts = self.find(
                :all,
                :conditions => ['discussion_id = ?', discussion.id],
                :limit      => limit,
                :offset     => offset,
                :order      => 'id ASC',
                :include    => [:user]
            )
            
            # Inject the pagination methods on the collection
            class << posts; include Paginates; end
            posts.setup_pagination(:total_count => posts_count, :page => page, :per_page => limit)

            return posts
        end

    end
    
    def body_html
        self.body.strip.gsub("\n", "<br />\n")
    end

    def edited?
        (self.created_at <=> self.updated_at) ? true : false
    end
    
end
