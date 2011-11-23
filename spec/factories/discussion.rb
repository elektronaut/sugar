FactoryGirl.define do
	factory :discussion do
		sequence(:title)  {|n| "Discussion #{n}"}
		sequence(:body)   {|n| "First post of discussion #{n}"}
		association :poster,      :factory => :user
		#association :last_poster, :factory => :user
		category
		trusted {|d| d.category.trusted}
		
		factory :closed_discussion do
			association :closer, :factory => :user
			closed true
		end
		
		factory :trusted_discussion do
			association :category, :factory => :trusted_category
		end
	end
end