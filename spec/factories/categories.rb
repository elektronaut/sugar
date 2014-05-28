FactoryGirl.define do
  factory :category do
    sequence(:name)        {|n| "Category #{n}"}
    trusted false

    factory :trusted_category do
      trusted true
    end
  end
end
