class DiscussionView < ActiveRecord::Base
    belongs_to :user
    belongs_to :discussion
    belongs_to :post
end
