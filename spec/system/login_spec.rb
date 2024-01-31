# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Logging in" do
  let(:user) { create(:user) }

  it "User logs in" do
    login_with(user.email, user.password)
    user_is_logged_in
  end
end
