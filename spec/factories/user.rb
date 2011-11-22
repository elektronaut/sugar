FactoryGirl.define do
	factory :user do
		sequence(:username) {|n| "lonelygirl#{n}"}
		sequence(:realname) {|n| "Sugar User #{n}"}
		email
		hashed_password     { FactoryGirl.generate(:sha1hash) }
		description         { "Hi, I'm #{realname}!" }
		sequence(:location) {|n| "Location #{n}"}

		admin      false
		user_admin false
		moderator  false
		activated  true
		banned     false
		trusted    false
	end
end