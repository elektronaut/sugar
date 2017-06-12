require "rails_helper"

describe UploadsController, redis: true do
  let(:user) { create(:user) }
  let(:png_file) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/support/pink.png"),
      "image/png"
    )
  end

  before do
    # Create the first admin user
    create(:user)
  end

  describe "POST create" do
    before { login(user) }

    context "with a valid file" do
      let(:last_image) { PostImage.last }
      let(:expected_response) do
        {
          type: "image/png",
          name: "pink.png",
          embed: "[image:#{last_image.id}:" \
            "76a68c6a781ef4919bd4352b880b7c9e50de3d96]"
        }
      end

      subject { response.body }
      before { post :create, params: { upload: { file: png_file } }, format: :json }

      it "should respond with JSON" do
        expect(response.header["Content-Type"]).to match "application/json"
      end

      it { is_expected.to be_json_eql(expected_response.to_json) }
    end
  end
end
