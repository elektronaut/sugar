module ExchangeParticipant
  extend ActiveSupport::Concern

  included do
    has_many   :discussions, :foreign_key => 'poster_id'
    has_many   :posts
    has_many   :discussion_posts, :class_name => 'Post', :conditions => {:conversation => false}
    has_many   :discussion_views, :dependent => :destroy
    has_many   :discussion_relationships, :dependent => :destroy

    has_many   :conversation_relationships, :dependent => :destroy
    has_many   :conversations, :through => :conversation_relationships
  end

  # Finds participated discussions.
  def participated_discussions(options={})
    DiscussionRelationship.find_participated(self, options)
  end

  # Finds followed discussions.
  def following_discussions(options={})
    DiscussionRelationship.find_following(self, options)
  end

  # Finds favorite discussions.
  def favorite_discussions(options={})
    DiscussionRelationship.find_favorite(self, options)
  end

  # Marks a discussion as viewed
  def mark_discussion_viewed(discussion, post, index)
    if discussion_view = DiscussionView.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
      discussion_view.update_attributes(:post_index => index, :post_id => post.id) if discussion_view.post_index < index
    else
      DiscussionView.create(:discussion_id => discussion.id, :user_id => self.id, :post_index => index, :post_id => post.id)
    end
  end

  # Finds and paginate discussions created by this user.
  # === Parameters
  # * <tt>:trusted</tt> - Boolean, includes discussions in trusted categories.
  # * <tt>:limit</tt>   - Number of discussions per page. Default: Exchange::DISCUSSIONS_PER_PAGE
  # * <tt>:page</tt>    - Page, defaults to 1.
  def paginated_discussions(options={})
    Pagination.paginate(
      :total_count => options[:trusted] ? self.discussions.count(:all) : self.discussions.count(:all, :conditions => {:trusted => false}),
      :per_page    => options[:limit] || Exchange::DISCUSSIONS_PER_PAGE,
      :page        => options[:page] || 1
    ) do |pagination|
      discussions = Discussion.find(
        :all,
        :conditions => options[:trusted] ? ['poster_id = ?', self.id] : ['poster_id = ? AND trusted = ?', self.id, false],
        :limit      => pagination.limit,
        :offset     => pagination.offset,
        :order      => 'sticky DESC, last_post_at DESC',
        :include    => [:poster, :last_poster, :category]
      )
    end
  end

  def paginated_conversations(options={})
    Pagination.paginate(
      :total_count => ConversationRelationship.count(:all, :conditions => {:user_id => self.id}),
      :per_page    => options[:limit] || Exchange::DISCUSSIONS_PER_PAGE,
      :page        => options[:page] || 1
    ) do |pagination|
      joins = "INNER JOIN conversation_relationships ON conversation_relationships.conversation_id = discussions.id"
      joins += " AND conversation_relationships.user_id = #{self.id}"
      conversations = Conversation.find(
        :all,
        :select     => 'discussions.*',
        :joins      => joins,
        :limit      => pagination.limit,
        :offset     => pagination.offset,
        :order      => 'discussions.last_post_at DESC',
        :include    => [:poster, :last_poster]
      )
    end
  end

  # Finds and paginate posts created by this user.
  # === Parameters
  # * <tt>:trusted</tt> - Boolean, includes posts in trusted categories.
  # * <tt>:limit</tt>   - Number of posts per page. Default: Post::POSTS_PER_PAGE
  # * <tt>:page</tt>    - Page, defaults to 1.
  def paginated_posts(options={})
    Pagination.paginate(
      :total_count => options[:trusted] ? self.discussion_posts.count(:all) : self.discussion_posts.count(:all, :conditions => {:conversation => false, :trusted => false}),
      :per_page    => options[:limit] || Post::POSTS_PER_PAGE,
      :page        => options[:page] || 1
    ) do |pagination|
      Post.find(
        :all,
        :conditions => options[:trusted] ? ['user_id = ? AND conversation = ?', self.id, false] : ['user_id = ? AND trusted = ? AND conversation = ?', self.id, false, false],
        :limit      => pagination.limit,
        :offset     => pagination.offset,
        :order      => 'created_at DESC',
        :include    => [:user, :discussion]
      )
    end
  end

  # Calculates messages per day, rounded to a number of decimals determined by <tt>precision</tt>.
  def posts_per_day(precision=2)
    ppd = posts_count.to_f / ((Time.now - self.created_at).to_f / 60 / 60 / 24)
    number = ppd.to_s.split(".")[0]
    scale = ppd.to_s.split(".")[1][0..(precision - 1)]
    "#{number}.#{scale}".to_f
  end

  def unread_conversations_count
    self.conversation_relationships.count(
      :all,
      :conditions => {:new_posts => true, :notifications => true}
    )
  end

  def unread_conversations?
    unread_conversations_count > 0
  end

  # Returns true if this user is following the given discussion.
  def following?(discussion)
    relationship = DiscussionRelationship.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
    relationship && relationship.following?
  end

  # Returns true if this user has favorited the given discussion.
  def favorite?(discussion)
    relationship = DiscussionRelationship.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', self.id, discussion.id])
    relationship && relationship.favorite?
  end

end