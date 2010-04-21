require 'faker'

Sham.define do
	name      { Faker::Name.name }
	email     { Faker::Internet.email }
	word(:unique => false)      { Faker::Lorem.words(1) }
	title     { Faker::Lorem.sentence }
	body      { Faker::Lorem.paragraph }
	hash      { Digest::SHA1.hexdigest( Sham.word ) }
	date      { Date.parse([(1990...2008),(1...12),(1...28)].map{|i| i.to_a.rand.to_s}.join('-')) }
	url       { "http://"+Faker::Internet.domain_name }
	flickr_id { (1..8).map{(1..10).to_a.rand}.join + "@" + (1..2).map{(1..10).to_a.rand}.join}
end

Category.blueprint do
	name { Sham.title }
	description { Sham.body }
	trusted false
end
Category.blueprint(:trusted) do
	trusted true
end

Discussion.blueprint do
	title
	body
	poster
	last_poster
	category
	trusted { category.trusted }
end

Post.blueprint do
	discussion
	user
	body
end

Message.blueprint do
	recipient
	sender
	subject { Sham.title }
	body
end

User.blueprint do
	username        { Sham.word }
	realname        { Sham.name }
	email           { Sham.email }
	hashed_password { Sham.hash }
	description     { Sham.body }
	location        { Sham.word }
	birthday        { Sham.date }
	stylesheet_url  { Sham.url }
	gamertag        { Sham.word }
	msn             { Sham.email }
	gtalk           { Sham.email }
	aim             { Sham.word }
	flickr          { Sham.flickr_id }
	last_fm         { Sham.word }
	website         { Sham.url }

	admin      false
	user_admin false
	moderator  false
	activated  true
	banned     false
	trusted    false
end

User.blueprint(:admin) do
	admin true
end
User.blueprint(:moderator) do
	moderator true
end
User.blueprint(:user_admin) do
	user_admin true
end
User.blueprint(:trusted) do
	trusted true
end
User.blueprint(:banned) do
	banned true
end