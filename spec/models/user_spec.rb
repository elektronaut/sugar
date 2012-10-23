# encoding: utf-8

require 'spec_helper'

describe User do

  let(:user) { create(:user) }
  subject { user }

  it { should be_kind_of(Authenticable) }
  it { should be_kind_of(Inviter) }
  it { should be_kind_of(ExchangeParticipant) }

  it { should validate_presence_of(:username) }
  it { should validate_uniqueness_of(:username).case_insensitive.with_message(/is already registered/) }
  xit { should validate_format_of(:username).with(/^[\p{Word}\d\-\s_#!]+$/).with_message(/is not valid/) }

  it { should allow_value("Gustave Moíre").for(:username) }
  it { should_not allow_value(";Bobby Tables").for(:username) }

  it { should validate_uniqueness_of(:email).case_insensitive.with_message(/is already registered/) }

  it { should allow_value("test@example.com").for(:email) }
  xit { should_not allow_value("test.example.com").for(:email) }

  describe "email validation" do
    context "when signed up with email" do
      pending
    end
    context "when signed up with Facebook" do
      pending
    end
    context "when signed up with OpenID" do
      pending
    end
  end

  describe "realname validation" do
    context "signup approval is required" do
      pending
    end
    context "signup approval isn't required" do
      pending
    end
  end

  describe "scopes" do
    pending
  end

  describe ".safe_attributes" do
    pending
  end

  describe "#full_email" do
    pending
  end

  describe "#realname_or_username" do
    pending
  end

  describe "#facebook?" do
    pending
  end

  describe "#online?" do
    pending
  end

  describe "#trusted?" do
    pending
  end

  describe "#user_admin?" do
    pending
  end

  describe "#moderator?" do
    pending
  end

  describe "#admin_labels" do
    pending
  end

  describe "#theme" do
    pending
  end

  describe "#mobile_theme" do
    pending
  end

  describe "#gamertag_avatar_url" do
    pending
  end

  describe "#as_json" do
    pending
  end

  describe "#to_xml" do
    pending
  end

end
