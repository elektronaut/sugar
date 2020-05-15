# frozen_string_literal: true

module Features
  def login_as(user = nil)
    user ||= create(:new_user)
    login_with(user.email, user.password)
  end

  def login_with(email, password)
    visit login_users_path
    fill_in "email", with: email
    fill_in "password", with: password
    click_button "Sign in"
  end

  def user_is_logged_in
    expect(page).to(have_text("Sign out"))
  end

  def user_is_logged_out
    expect(page).not_to(have_text("Sign out"))
  end
end
