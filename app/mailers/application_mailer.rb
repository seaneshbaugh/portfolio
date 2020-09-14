# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'sean@seaneshbaugh.com'

  layout 'mailer'
end
