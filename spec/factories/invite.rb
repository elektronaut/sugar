FactoryGirl.define do
  factory :invite do
    sequence(:message)  {|n| "Random message #{n}"}
    email
    user
  end
end