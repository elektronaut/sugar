require 'post_parser'

class Post < ActiveRecord::Base
    
    POSTS_PER_PAGE = 50

    belongs_to :user, :counter_cache => true
    belongs_to :discussion, :counter_cache => true
    
    validates_presence_of :body
    
    # Automatically update the discussion with last poster info
    after_create do |post|
        post.discussion.update_attributes(:last_poster_id => post.user.id, :last_post_at => post.created_at)
    end
    
    before_save do |post|
        post.body_html = PostParser.parse(post.body)
    end
    
    class << self

        def find_paginated(options={})
            discussion = options[:discussion]
            posts_count = discussion.posts_count

            # Math is still awesome
            limit = options[:limit] || POSTS_PER_PAGE
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
    
    # Get this posts sequence number
    def post_number
        @post_number ||= ( Post.count_by_sql("SELECT COUNT(*) FROM posts WHERE discussion_id = #{self.discussion.id} AND created_at < '#{self.created_at.to_formatted_s(:db)}'") + 1)
    end

    def page(options={})
        limit = options[:limit] || POSTS_PER_PAGE
        (post_number.to_f/limit).ceil
    end

    def body_html
        unless body_html?
            self.update_attribute(:body_html, PostParser.parse(self.body.dup))
        end
        self[:body_html]
    end

    def edited?
        return false
        return false unless edited_at?
        (((self.edited_at || self.created_at), - self.created_at) > 5.seconds ) ? true : false
    end
    
    def editable_by?(user)
        (user && (user.admin? || user == self.user)) ? true : false
    end
    
    def viewable_by?(user)
        (user && !(self.discussion.trusted? && !(user.trusted? || user.admin?))) ? true : false
    end
end
