# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :password_reset_token do
    user
  end
end
