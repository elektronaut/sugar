FactoryGirl.define do
  factory :post do
    sequence(:body) {|n| "Post body #{n}"}
    association :exchange, :factory => :discussion
    user

    factory :trusted_post do
      association :exchange, :factory => :trusted_discussion
    end
  end
end
