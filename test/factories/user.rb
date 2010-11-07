Factory.define :user do |u|
	u.sequence(:username) {|n| "lonelygirl#{n}"}
	u.sequence(:realname) {|n| "Sugar User #{n}"}
	u.email               {Factory.next(:email)}
	u.hashed_password     {Factory.next(:sha1hash)}
	u.description         {|u| "Hi, I'm #{u.realname}!"}
	u.sequence(:location) {|n| "Location #{n}"}
	u.admin      false
	u.user_admin false
	u.moderator  false
	u.activated  true
	u.banned     false
	u.trusted    false
end