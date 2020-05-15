# frozen_string_literal: true

class PostSerializer
  include FastJsonapi::ObjectSerializer
  set_type :post
  attributes :id, :body_html, :created_at, :edited_at, :updated_at
  belongs_to :user
  belongs_to :exchange
end
