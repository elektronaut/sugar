FactoryGirl.define do
  factory :post_image do
    file Rack::Test::UploadedFile.new(
      Rails.root.join("spec/support/pink.png"),
      "image/png"
    )
  end
end
