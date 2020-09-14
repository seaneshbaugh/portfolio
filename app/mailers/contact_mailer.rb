# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def contact_form_message(contact)
    @contact = contact

    mail to: 'seaneshbaugh@gmail.com', subject: "seaneshbaugh.com Contact Form - #{@contact.subject}"
  end
end
