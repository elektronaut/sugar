FactoryGirl.define do
  factory :invite do
    email
    user
    factory :expired_invite do
      expires_at { 2.days.ago }
    end
  end
end
