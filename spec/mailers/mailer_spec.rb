require "rails_helper"

describe Mailer do
  let(:user)      { create(:new_user) }
  let(:invite)    { create(:invite) }
  let(:login_url) { "http://example.com/login" }

  before do
    Sugar.config.forum_name = "Sugar"
    Sugar.config.mail_sender = "test@example.com"
  end

  describe "invite" do
    let(:mail) { Mailer.invite(invite, login_url) }

    specify do
      expect(
        mail.subject
      ).to eq("#{invite.user.realname} has invited you to Sugar!")
    end
    specify { expect(mail.to).to eq([invite.email]) }
    specify { expect(mail.from).to eq(["test@example.com"]) }

    describe "its body" do
      subject { mail.body.encoded }

      it { is_expected.to match(Sugar.config.forum_name) }
      it { is_expected.to match(invite.user.realname) }
      it { is_expected.to match(login_url) }

      context "when invite has message" do
        let(:invite) { create(:invite, message: "My message") }
        it { is_expected.to match("My message") }
      end
    end
  end

  describe "new_user" do
    let(:mail) { Mailer.new_user(user, login_url) }

    specify { expect(mail.subject).to eq("Welcome to Sugar!") }
    specify { expect(mail.to).to eq([user.email]) }
    specify { expect(mail.from).to eq(["test@example.com"]) }

    describe "its body" do
      subject { mail.body.encoded }

      context "when signed up with password" do
        it { is_expected.to match(user.username) }
        it { is_expected.to match(login_url) }
      end

      context "when signed up with OpenID" do
        let(:user) { create(:new_user, openid_url: "http://example.com/") }
        it { is_expected.to match(user.openid_url) }
        it { is_expected.to match(user.username) }
      end
    end
  end

  describe "password_reset" do
    let(:mail) do
      Mailer.password_reset("user@example.com", "http://example.com")
    end
    subject { mail }

    specify { expect(mail.subject).to eq("Password reset for Sugar") }
    specify { expect(mail.to).to eq(["user@example.com"]) }
    specify { expect(mail.from).to eq(["test@example.com"]) }
    specify { expect(mail.body.encoded).to match("http://example.com") }
  end
end
