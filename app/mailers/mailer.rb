# encoding: utf-8

class Mailer < ActionMailer::Base

  default :from => Proc.new { Sugar.config(:mail_sender) || 'no-reply@example.com' }

  # Send an invite
  def invite(invite, login_url)
    @invite    = invite
    @login_url = login_url
    mail(
      :to      => @invite.email,
      :subject => "#{@invite.user.realname_or_username} has invited you to #{Sugar.config(:forum_name)}!"
    )
  end

  # Send a welcome mail to a new user
  def new_user(user, login_url)
    @user      = user
    @login_url = login_url
    mail(
      :to      => @user.email,
      :subject => "Welcome to #{Sugar.config(:forum_name)}!"
    )
  end

  # Send a password reset request
  def password_reset(email, url)
    @url = url
    mail(
      to: email,
      subject: "Password reset for #{Sugar.config(:forum_name)}"
    )
  end

end
