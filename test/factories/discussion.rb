Factory.define :discussion do |d|
	d.sequence(:title)  {|n| "Discussion #{n}"}
	d.sequence(:body)   {|n| "First post of discussion #{n}"}
	d.association :poster, :factory => :user
	d.association :last_poster, :factory => :user
	d.association :category
	d.trusted           {|d| d.category.trusted}
end