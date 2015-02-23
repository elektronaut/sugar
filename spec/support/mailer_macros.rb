module MailerMacros
  def email_deliveries
    ActionMailer::Base.deliveries
  end

  def last_email
    email_deliveries.last
  end

  def reset_email
    ActionMailer::Base.deliveries = []
  end
end
