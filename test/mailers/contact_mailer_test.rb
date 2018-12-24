# frozen_string_literal: true

require 'test_helper'

class ContactMailerTest < ActionMailer::TestCase
  test 'contact form message' do
    contact = Contact.new(name: 'Test Contact', email: 'test@test.com', phone_number: '+1 214-123-4567', subject: 'Hello!', body: 'This is a test.')

    email = ContactMailer.contact_form_message(contact).deliver

    assert !ActionMailer::Base.deliveries.empty?

    assert_equal ['seaneshbaugh@gmail.com'], email.to

    assert_equal 'seaneshbaugh.com Contact Form - Hello!', email.subject

    assert_match '<h1>New Contact Form Message</h1>', email.encoded
  end
end
