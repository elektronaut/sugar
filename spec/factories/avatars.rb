FactoryGirl.define do
  factory :avatar do
    file Rack::Test::UploadedFile.new(
      Rails.root.join("spec/support/pink.png"),
      "image/png"
    )
  end
end
