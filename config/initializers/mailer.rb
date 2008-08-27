require "smtp_tls"

ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    :authentication => :plain,
    :user_name => "noreply@butt3rscotch.org",
    :password => 'SMTP404b3s'
}
