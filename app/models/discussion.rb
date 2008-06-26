class Discussion < ActiveRecord::Base
    
    belongs_to :poster, :class_name => 'User', :counter_cache => true
    belongs_to :last_poster, :class_name => 'User'
    belongs_to :category
    has_many   :posts, :order => ['created_at ASC']

    validates_presence_of :user_id, :category_id, :title
    
end
