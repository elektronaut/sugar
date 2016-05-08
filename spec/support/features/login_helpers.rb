module Features
  def login_as(user = nil)
    user ||= create(:new_user)
    login_with(user.username, user.password)
  end

  def login_with(username, password)
    visit login_users_path
    fill_in "username", with: username
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
