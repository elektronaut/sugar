require "rails_helper"

RSpec.feature "Logging in", type: :feature do
  let(:user) { create(:new_user) }

  scenario "User logs in" do
    login_with(user.email, user.password)
    user_is_logged_in
  end
end
