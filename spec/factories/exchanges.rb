FactoryGirl.define do
  factory :exchange do
    sequence(:title)  {|n| "Exchange #{n}"}
    sequence(:body)   {|n| "First post of exchange #{n}"}
    association :poster, factory: :user

    # Discussions
    factory :discussion, class: 'discussion' do
      sequence(:title)  {|n| "Discussion #{n}"}
      sequence(:body)   {|n| "First post of discussion #{n}"}

      factory :closed_discussion do
        association :closer, factory: :user
        closed true
      end

      factory :trusted_discussion do
        trusted true
      end
    end

    # Conversations
    factory :conversation, class: 'conversation' do
      sequence(:title)  {|n| "Conversation #{n}"}
      sequence(:body)   {|n| "First post of conversation #{n}"}
    end
  end
end
