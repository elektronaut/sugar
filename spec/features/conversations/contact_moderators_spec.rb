# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contact moderators" do
  let!(:admin) { create(:admin) }
  let!(:user) { create(:new_user) }

  before do
    login_with(user.email, user.password)
    visit conversations_url
  end

  it "User contacts moderators" do
    click_link "Contact moderators"
    fill_in "conversation[title]", with: "Title"
    fill_in "conversation[body]", with: "Body"
    click_button "Create conversation"
    expect(page).to have_link(admin.username)
  end
end
