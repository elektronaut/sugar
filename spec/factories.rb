FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :sha1hash do |n|
    Digest::SHA1.hexdigest(n.to_s)
  end
end
