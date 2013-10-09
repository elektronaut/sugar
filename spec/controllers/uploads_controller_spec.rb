require 'spec_helper'

describe UploadsController, redis: true do

  let(:user)          { create(:user) }
  let(:png_file)      { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/pink.png"), "image/png") }

  before do
    # Create the first admin user
    create(:user)

    # Configure S3
    Sugar.config(:amazon_aws_key,    "foo")
    Sugar.config(:amazon_aws_secret, "bar")
    Sugar.config(:amazon_s3_bucket,  "sugar")
    Sugar.save_config!
  end

  specify { Sugar.aws_s3?.should == true }

  describe "POST create" do
    before { login(user) }

    context "with a valid file" do
      let(:expected_response) do
        {
          type: "image/png",
          name: "pink.png",
          url:  "https://s3.amazonaws.com/sugar/76a68c6a781ef4919bd4352b880b7c9e50de3d96.png"
        }
      end

      subject { response.body }
      before { post :create, upload: { file: png_file }, format: :json }

      it "should respond with JSON" do
        response.header["Content-Type"].should match "application/json"
      end

      it { should be_json_eql(expected_response.to_json) }
    end
  end

end
