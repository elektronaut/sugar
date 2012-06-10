FactoryGirl.define do
  factory :exchange do
    sequence(:title)  {|n| "Exchange #{n}"}
    sequence(:body)   {|n| "First post of exchange #{n}"}
    association :poster, :factory => :user

    # Discussions
    factory :discussion, :class => Discussion do
      sequence(:title)  {|n| "Discussion #{n}"}
      sequence(:body)   {|n| "First post of discussion #{n}"}
      category
      trusted {|d| d.category.trusted}

      factory :closed_discussion do
        association :closer, :factory => :user
        closed true
      end

      factory :trusted_discussion do
        association :category, :factory => :trusted_category
      end
    end

    # Conversations
    factory :conversation, :class => Conversation do
      sequence(:title)  {|n| "Conversation #{n}"}
      sequence(:body)   {|n| "First post of conversation #{n}"}
    end
  end
end