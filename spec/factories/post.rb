FactoryGirl.define do
  factory :post do
    sequence(:body) {|n| "Post body #{n}"}
    discussion
    user

    factory :trusted_post do
      association :discussion, :factory => :trusted_discussion
    end
  end
end
