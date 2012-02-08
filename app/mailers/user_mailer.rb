class UserMailer < ActionMailer::Base
  default :from => "sean@seaneshbaugh.com"

  def password_reset(user)
    @user = user

    mail :to => user.email_address, :subject => "seaneshbaugh.com - Password Reset"
  end
end
