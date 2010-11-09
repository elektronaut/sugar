Factory.define :invite do |i|
	i.email               {Factory.next(:email)}
	i.sequence(:message)  {|n| "Random message #{n}"}
	i.association :user
end