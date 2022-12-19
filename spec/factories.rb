# frozen_string_literal: true

FactoryBot.define do
  factory :avatar do
    file do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/support/pink.png"),
        "image/png"
      )
    end
  end

  factory :conversation_relationship do
    user
    conversation
  end

  factory :discussion_relationship do
    user
    discussion
  end

  factory :exchange_moderator do
    association :exchange, factory: :discussion
    user
  end

  factory :exchange_view do
    user
    exchange
    post { exchange.posts.first }
  end

  factory :exchange do
    sequence(:title)  { |n| "Exchange #{n}" }
    sequence(:body)   { |n| "First post of exchange #{n}" }
    association :poster, factory: :user
    posts_count { 1 }

    # Discussions
    factory :discussion, class: "discussion" do
      sequence(:title)  { |n| "Discussion #{n}" }
      sequence(:body)   { |n| "First post of discussion #{n}" }

      factory :closed_discussion do
        association :closer, factory: :user
        closed { true }
      end
    end

    # Conversations
    factory :conversation, class: "conversation" do
      sequence(:title)  { |n| "Conversation #{n}" }
      sequence(:body)   { |n| "First post of conversation #{n}" }
    end
  end

  factory :invite do
    email
    user
    factory :expired_invite do
      expires_at { 2.days.ago }
    end
  end

  factory :post_image do
    file do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/support/pink.png"),
        "image/png"
      )
    end
  end

  factory :post do
    sequence(:body) { |n| "Post body #{n}" }
    association :exchange, factory: :discussion
    user
  end

  factory :user do
    sequence(:username) { |n| "lonelygirl#{n}" }
    sequence(:realname) { |n| "Sugar User #{n}" }
    email
    hashed_password     { FactoryBot.generate(:sha1hash) }
    description         { "Hi, I'm #{realname}!" }
    sequence(:location) { |n| "Location #{n}" }

    admin { false }
    user_admin { false }
    moderator { false }
    status { :active }

    factory :admin do
      admin { true }
    end

    factory :moderator do
      moderator { true }
    end

    factory :new_user do
      password { "foobar" }
      confirm_password { "foobar" }
      hashed_password { nil }
    end

    factory :user_admin do
      user_admin { true }
    end

    factory :banned_user do
      status { :banned }
    end

    factory :facebook_user do
      sequence(:facebook_uid, &:to_s)
      hashed_password { nil }
    end

    factory :user_with_avatar do
      association :avatar, factory: :avatar
    end
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :sha1hash do |n|
    Digest::SHA1.hexdigest(n.to_s)
  end
end
