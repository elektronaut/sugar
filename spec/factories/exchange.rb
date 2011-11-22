FactoryGirl.define do
	factory :exchange do
		sequence(:title)  {|n| "Exchange #{n}"}
		sequence(:body)   {|n| "First post of exchange #{n}"}
		association :poster, :factory => :user
		association :last_poster, :factory => :user
	end
end