class Message < ActiveRecord::Base

    MESSAGES_PER_PAGE = 30

    belongs_to :recipient, :class_name => 'User'
    belongs_to :sender, :class_name => 'User'
    
    def replied?
        replied_at? ? true : false
    end

    def body_html
        #unless body_html?
        #    self.update_attribute(:body_html, PostParser.parse(self.body.dup))
        #end
        #self[:body_html]
        PostParser.parse(self.body.dup)
    end
    
    def page(options={})
        options[:limit] ||= MESSAGES_PER_PAGE
        count = Message.count(:all, :conditions => ["(recipient_id = ? AND sender_id = ?) OR (sender_id = ? AND recipient_id = ?) AND created_at <= ?", self.recipient_id, self.sender_id, self.recipient_id, self.sender_id, self.created_at])
        if count > 0
            (count.to_f / options[:limit]).ceil
        else
            1
        end
    end

end
