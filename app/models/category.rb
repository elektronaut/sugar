class Category < ActiveRecord::Base
    
    has_many :discussions
    
    validates_presence_of :name
    
    acts_as_list
    
    def to_param
        "#{self.id}-" + self.name.downcase.gsub(/[^\w\d]+/,'_')
    end
    
end
