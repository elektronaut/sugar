FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "lonelygirl#{n}"}
    sequence(:realname) {|n| "Sugar User #{n}"}
    email
    hashed_password     { FactoryGirl.generate(:sha1hash) }
    description         { "Hi, I'm #{realname}!" }
    sequence(:location) {|n| "Location #{n}"}

    admin      false
    user_admin false
    moderator  false
    activated  true
    banned     false
    trusted    false

    factory :admin do
      admin true
    end

    factory :moderator do
      moderator true
    end

    factory :new_user do
      password 'foobar'
      confirm_password 'foobar'
      hashed_password nil
    end

    factory :user_admin do
      user_admin true
    end

    factory :trusted_user do
      trusted true
    end

    factory :banned_user do
      banned true
    end
  end
end
