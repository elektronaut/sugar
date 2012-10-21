# encoding: utf-8

class DiscussionRelationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion

  after_save do |relationship|
    relationship.update_user_caches!
  end

  after_destroy do |relationship|
    relationship.update_user_caches!
  end

  class << self
    # Define a relationship with a discussion
    def define(user, discussion, options={})
      relationship = self.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', user.id, discussion.id])
      relationship ||= DiscussionRelationship.create(:user_id => user.id, :discussion_id => discussion.id)
      relationship.update_attributes(options.merge({:trusted => discussion.trusted}))
      relationship.save
      relationship
    end

    # Find participated discussions for a user
    def find_participated(user, options={})
      self.find_discussions(user, {:participated => true}.merge(options))
    end

    # Find followed discussions for a user
    def find_following(user, options={})
      self.find_discussions(user, {:following => true}.merge(options))
    end

    # Find favorite discussions for a user
    def find_favorite(user, options={})
      self.find_discussions(user, {:favorite => true}.merge(options))
    end

    def find_discussions(user, options={})
      conditions = options.select do |k, v|
        [:participated, :following, :favorite].include?(k)
      end
      conditions[:user_id] = user.id
      conditions[:trusted] = false unless options[:trusted]

      discussions = Discussion
        .select("#{Discussion.table_name}.*")
        .order('sticky DESC, last_post_at DESC')
        .includes(:poster, :last_poster, :category)
        .joins(:discussion_relationships)
        .where(:discussion_relationships => conditions)

      if options.has_key?(:page)
        limit     = options[:limit] || Exchange::DISCUSSIONS_PER_PAGE
        discussions_count = self.count(:all, :conditions => conditions)
        num_pages = (discussions_count.to_f/limit).ceil
        page      = (options[:page] || 1).to_i
        page      = 1 if page < 1
        page      = num_pages if page > num_pages
        offset    = limit * (page - 1)
        offset    = 0 if offset < 0

        discussions = discussions
          .limit(limit)
          .offset(offset)
      end

      discussions = discussions.all

      if options.has_key?(:page)
        Pagination.apply(
          discussions,
          Pagination::Paginater.new(
            :total_count => discussions_count,
            :page => page,
            :per_page => limit
          )
        )
      end
      discussions
    end
  end

  def update_user_caches!
    self.user.update_attributes({
      :participated_count => DiscussionRelationship.count(:all, :conditions => ['user_id = ? AND participated = ?', self.user.id, true]),
      :following_count    => DiscussionRelationship.count(:all, :conditions => ['user_id = ? AND following = ?', self.user.id, true]),
      :favorites_count    => DiscussionRelationship.count(:all, :conditions => ['user_id = ? AND favorite = ?', self.user.id, true])
    })
  end
end
