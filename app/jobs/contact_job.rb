# frozen_string_literal: true

class ContactJob < ApplicationJob
  queue_as :contact

  def perform(*args)
    @contact = Contact.new(JSON.parse(args.first))

    ContactMailer.contact_form_message(@contact).deliver
  end
end
