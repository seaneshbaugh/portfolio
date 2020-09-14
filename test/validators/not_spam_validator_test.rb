# frozen_string_literal: true

require 'test_helper'

class NotSpamValidatorTest < ActiveSupport::TestCase
  test 'not spam' do
    contact = Contact.new(name: 'Test Contact', email: 'test@test.com', subject: 'Test', body: 'testing 1 2 3')

    assert contact.valid?
  end

  test 'spam' do
    NotSpamValidator::SPAM_PHRASES.each do |spam|
      contact = Contact.new(name: 'Test Contact', email: 'test@test.com', subject: 'Test', body: "testing #{spam} 1 2 3")

      assert_not contact.valid?

      assert_equal(['is spam'], contact.errors[:body])
    end
  end
end
