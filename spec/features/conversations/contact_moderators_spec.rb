# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contact moderators" do
  let!(:admin) { create(:admin) }
  let!(:user) { create(:user) }

  before do
    login_with(user.email, user.password)
    visit conversations_url
  end

  it "User contacts moderators" do
    click_on "Contact moderators"
    fill_in "conversation[title]", with: "Title"
    fill_in "conversation[body]", with: "Body"
    click_on "Create conversation"
    expect(page).to have_link(admin.username)
  end
end
