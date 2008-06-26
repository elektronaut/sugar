class Post < ActiveRecord::Base

    belongs_to :user, :counter_cache => true
    belongs_to :discussion, :counter_cache => true
    
    validates_presence_of :user_id, :discussion_id, :body
    
    def edited?
        (self.edited_at?) ? true : false
    end
    
end
