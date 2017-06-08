class Avatar < ActiveRecord::Base
  include DynamicImage::Model
  has_one :user
end
