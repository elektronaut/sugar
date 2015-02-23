# encoding: utf-8

require "spec_helper"

describe Configuration, redis: true do
  let(:configuration) { Configuration.new }

  describe ".settings" do
    subject { Configuration.settings }
    it { is_expected.to be_a(Hash) }
  end

  describe ".setting" do
    before do
      Configuration.class_eval do
        setting :foo, :string
      end
    end

    it "should define a reader" do
      expect(configuration.foo).to eq(nil)
      expect { configuration.foo("baz") }.not_to raise_error
      expect(configuration.foo).to eq("baz")
    end

    it "should define a boolean reader" do
      expect(configuration.foo?).to eq(false)
    end

    it "should define a writer" do
      expect { configuration.foo = "bar" }.not_to raise_error
      expect(configuration.foo).to eq("bar")
    end
  end

  describe "#get" do
    subject { configuration.get(setting) }

    context "when setting exists" do
      let(:setting) { :forum_name }
      it { is_expected.to eq("Sugar") }
    end

    context "when setting doesn't exist" do
      let(:setting) { :inexistant }
      it "should raise an error" do
        expect { subject }.to raise_error(
          Configuration::InvalidConfigurationKey
        )
      end
    end
  end

  describe "#set" do
    subject { configuration.set(setting, value) }

    context "when setting exists" do
      let(:setting) { :forum_name }
      let(:value) { "Foo" }
      it { is_expected.to eq("Foo") }
    end

    context "when setting doesn't exist" do
      let(:setting) { :inexistant }
      let(:value) { "Foo" }
      it "should raise an error" do
        expect { subject }.to raise_error(
          Configuration::InvalidConfigurationKey
        )
      end
    end

    context "when value is an invalid type" do
      let(:setting) { :forum_name }
      let(:value) { 1.0 }
      it "should raise an error" do
        expect { subject }.to raise_error(
          ArgumentError
        )
      end
    end
  end

  describe "#load" do
    let(:other_configuration) { Configuration.new }

    before do
      other_configuration.update(forum_name: "Test")
    end

    it "should load the configuration from Redis" do
      expect(configuration.forum_name).to eq("Sugar")
      configuration.load
      expect(configuration.forum_name).to eq("Test")
    end
  end

  describe "#save" do
    let(:other_configuration) { Configuration.new }

    it "should save the configuration to Redis" do
      configuration.forum_name = "Save test"
      expect(other_configuration.forum_name).to eq("Sugar")
      configuration.save
      other_configuration.load
      expect(other_configuration.forum_name).to eq("Save test")
    end
  end

  describe "#update" do
    let(:other_configuration) { Configuration.new }

    it "should update the configuration" do
      expect(other_configuration.forum_name).to eq("Sugar")
      configuration.update(forum_name: "Update test")
      other_configuration.load
      expect(other_configuration.forum_name).to eq("Update test")
    end
  end

  describe "#reset!" do
    before { configuration.forum_name = "Reset test" }

    it "should reset the configuration" do
      expect(configuration.forum_name).to eq("Reset test")
      configuration.reset!
      expect(configuration.forum_name).to eq("Sugar")
    end
  end
end
