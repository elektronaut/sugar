# frozen_string_literal: true

module DiscussionRelationshipsController
  extend ActiveSupport::Concern

  def follow
    define_relationship(:following, true)
  end

  def unfollow
    define_relationship(:following, false, back_to_index: true)
  end

  def favorite
    define_relationship(:favorite, true)
  end

  def unfavorite
    define_relationship(:favorite, false, back_to_index: true)
  end

  def hide
    define_relationship(:hidden, true, back_to_index: true)
  end

  def unhide
    define_relationship(:hidden, false)
  end

  private

  def define_relationship(key, value, back_to_index: false)
    DiscussionRelationship.define(current_user, @exchange, key => value)
    if back_to_index
      redirect_to discussions_url
    else
      redirect_to discussion_url(@exchange, page: params[:page])
    end
  end
end
