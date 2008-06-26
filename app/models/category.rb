class Category < ActiveRecord::Base
    
    has_many :discussions
    
end
