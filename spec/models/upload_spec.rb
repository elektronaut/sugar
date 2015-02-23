# encoding: utf-8

require "spec_helper"

describe Upload do
  let(:png_file) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/support/pink.png"),
      "image/png"
    )
  end

  let(:ruby_file) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("config/application.rb"),
      "text/plain"
    )
  end

  let(:hexdigest) { "76a68c6a781ef4919bd4352b880b7c9e50de3d96" }
  let(:upload) { Upload.new(png_file) }

  before do
    # Create the first admin user
    create(:user)

    # Configure S3
    Sugar.config.update(
      amazon_aws_key: "foo",
      amazon_aws_secret: "bar",
      amazon_s3_bucket: "sugar"
    )

    AWS.stub!
  end

  describe ".create" do
    context "with a valid file" do
      let(:upload) { Upload.create(png_file) }
      subject { upload }

      it { is_expected.to be_an(Upload) }
      specify { expect(upload.valid?).to eq(true) }
    end
  end

  describe "#s3_bucket" do
    subject { upload.s3_bucket }
    it { is_expected.to be_a(AWS::S3::Bucket) }
  end

  describe "#s3_object" do
    subject { upload.s3_object }
    it { is_expected.to be_a(::AWS::S3::Object) }
  end

  describe "#name" do
    subject { upload.name }

    context "when name isn't set" do
      it { is_expected.to eq("pink.png") }
    end

    context "when name is set" do
      let(:upload) { Upload.new(png_file, name: "foo.png") }
      it { is_expected.to eq("foo.png") }
    end
  end

  describe "#mime_type" do
    subject { upload.mime_type }

    context "when file is a PNG" do
      it { is_expected.to eq("image/png") }
    end

    context "when file is a text file" do
      let(:upload) { Upload.new(ruby_file) }
      it { is_expected.to eq("text/x-ruby") }
    end
  end

  describe "#filename" do
    subject { upload.filename }

    context "when name isn't set" do
      it { is_expected.to eq("#{hexdigest}.png") }
    end

    context "when name is set" do
      let(:upload) { Upload.new(png_file, name: "foo.jpg") }
      it { is_expected.to eq("#{hexdigest}.jpg") }
    end
  end

  describe "#hexdigest" do
    subject { upload.hexdigest }
    it { is_expected.to eq(hexdigest) }
  end

  describe "#save" do
    it "should save the object" do
      s3_object = double(exists?: false)
      allow(upload).to receive(:s3_object).and_return(s3_object)
      expect(s3_object).to receive(:write)
      upload.save
    end
  end

  describe "#exists?" do
    subject { upload.exists? }

    context "when file doesn't exist" do
      before do
        allow(upload).to receive(:s3_object).
          and_return(double(exists?: false))
      end
      it { is_expected.to eq(false) }
    end

    context "when file exists" do
      before { upload.save }
      it { is_expected.to eq(true) }
    end
  end

  describe "#url" do
    subject { upload.url }
    it { is_expected.to eq("https://sugar.s3.amazonaws.com/#{hexdigest}.png") }
  end

  describe "#valid?" do
    subject { upload.valid? }

    context "when file isn't set" do
      let(:upload) { Upload.new(nil) }
      it { is_expected.to eq(false) }
    end

    context "when file is an image" do
      it { is_expected.to eq(true) }
    end

    context "when file is another type" do
      let(:upload) { Upload.new(ruby_file) }
      it { is_expected.to eq(false) }
    end
  end
end
