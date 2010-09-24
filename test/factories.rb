Factory.sequence :email do |n|
	"person#{n}@example.com"
end

Factory.sequence :sha1hash do |n|
	Digest::SHA1.hexdigest("#{n}")
end

