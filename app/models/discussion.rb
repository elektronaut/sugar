require 'paginates'

class Discussion < ActiveRecord::Base

    REJECT_PARAMS = :id, :sticky, :user_id, :last_poster_id, :posts_count, :created_at, :last_post_at

    belongs_to :poster, :class_name => 'User', :counter_cache => true
    belongs_to :last_poster, :class_name => 'User'
    belongs_to :category
    has_many   :posts, :order => ['created_at ASC']

    validates_presence_of :category_id, :title
    validates_presence_of :body, :on => :create
    
    attr_accessor :body
    
    after_update do |discussion|
        if discussion.body && !discussion.body.empty?
            discussion.posts.first.update_attribute(:body, discussion.body)
        end
    end
    
    class << self

        # Finds paginated discussions. 
        def find_paginated(options)
            discussions_count = (options[:category]) ? options[:category].discussions.count : Discussion.count
            conditions        = (options[:category]) ? ['category_id = ?', options[:category].id] : nil

            # Math is awesome
            limit = options[:limit] || 5
            num_pages = (discussions_count.to_f/limit).ceil
            page  = (options[:page] || 1).to_i
            page = 1 if page < 1
            page = num_pages if page > num_pages
            offset = limit * (page - 1)

            # Grab the discussions
            discussions = self.find(
                :all, 
                :conditions => conditions, 
                :limit      => limit, 
                :offset     => offset, 
                :order      => 'sticky DESC, last_post_at DESC',
                :include    => [:poster, :last_poster, :category]
            )

            # Inject the pagination methods on the collection
            class << discussions; include Paginates; end
            discussions.setup_pagination(num_pages, page, discussions_count, offset)

            return discussions
        end

    	def safe_attributes(params)
    	    safe_params = params.dup
    	    REJECT_PARAMS.each do |r|
    	        safe_params.delete(r)
            end
            return safe_params
        end

    end
    
    def create_first_post!
        self.posts.create(:user => self.poster, :body => self.body)
    end
    
    def labels?
        (self.closed? || self.sticky? || self.nsfw?) ? true : false
    end
    
    def labels
        labels = []
        labels << "Sticky" if self.sticky?
        labels << "Closed" if self.closed?
        labels << "NSFW" if self.nsfw?
        labels
    end
    
    def editable_by?(user)
        (user && (user.admin? || user == self)) ? true : false
    end

end
