Factory.define :category do |c|
	c.sequence(:name)        {|n| "Category #{n}"}
	c.sequence(:description) {|n| "Description of category #{n}"}
	c.trusted false
end

Factory.define :trusted_category, :parent => :category do |c|
	c.trusted true
end
