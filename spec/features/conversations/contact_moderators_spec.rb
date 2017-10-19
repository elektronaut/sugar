require "rails_helper"

RSpec.feature "Contact moderators", type: :feature do
  let!(:admin) { create(:admin) }
  let!(:user) { create(:new_user) }

  before do
    login_with(user.email, user.password)
  end

  scenario "User contacts moderators" do
    click_link "Conversations"
    click_link "Contact moderators"
    fill_in "conversation[title]", with: "Title"
    fill_in "conversation[body]", with: "Body"
    click_button "Create conversation"
    expect(page).to have_link(admin.username)
  end
end
