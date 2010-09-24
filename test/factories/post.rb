Factory.define :post do |p|
	p.discussion      {|c| c.association(:discussion)}
	p.user            {|c| c.association(:user)}
	p.sequence(:body) {|n| "Post body #{n}"}
end