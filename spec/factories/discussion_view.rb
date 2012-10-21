FactoryGirl.define do
  factory :discussion_view do
    user
    discussion
    post { discussion.posts.first }
  end
end
