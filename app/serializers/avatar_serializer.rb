# frozen_string_literal: true

class AvatarSerializer < ActiveModel::Serializer
  attributes :id, :content_hash, :content_type, :content_length, :filename,
             :colorspace, :real_width, :real_height, :crop_width, :crop_height,
             :crop_start_x, :crop_start_y, :crop_gravity_x, :crop_gravity_y
end
