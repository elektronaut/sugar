require "spec_helper"

describe UploadsController, redis: true do

  let(:user)          { create(:user) }
  let(:png_file)      { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/pink.png"), "image/png") }

  before do
    # Create the first admin user
    create(:user)

    # Configure S3
    Sugar.config.update(
      amazon_aws_key:    "foo",
      amazon_aws_secret: "bar",
      amazon_s3_bucket:  "sugar"
    )

    AWS.stub!
  end

  specify { expect(Sugar.aws_s3?).to eq(true) }

  describe "POST create" do
    before { login(user) }

    context "with a valid file" do
      let(:expected_response) do
        {
          type: "image/png",
          name: "pink.png",
          url:  "https://sugar.s3.amazonaws.com/76a68c6a781ef4919bd4352b880b7c9e50de3d96.png"
        }
      end

      subject { response.body }
      before { post :create, upload: { file: png_file }, format: :json }

      it "should respond with JSON" do
        expect(response.header["Content-Type"]).to match "application/json"
      end

      it { is_expected.to be_json_eql(expected_response.to_json) }
    end
  end

end
