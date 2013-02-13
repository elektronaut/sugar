module SearchablePost
  extend ActiveSupport::Concern

  included do
    searchable do
      text    :body
      integer :user_id
      integer :discussion_id
      time    :created_at
      time    :updated_at
      boolean :trusted
      boolean :conversation
    end
  end

end