# encoding: utf-8

class Mailer < ActionMailer::Base

  default :from => Proc.new { Sugar.config(:mail_sender) }

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

  # Send a password reminder
  def password_reminder(user, login_url)
    @user      = user
    @login_url = login_url
    mail(
      :to      => @user.email,
      :subject => "Your login details at #{Sugar.config(:forum_name)}"
    )
  end

end
