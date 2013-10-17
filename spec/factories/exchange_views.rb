FactoryGirl.define do
  factory :exchange_view do
    user
    exchange
    post { exchange.posts.first }
  end
end
