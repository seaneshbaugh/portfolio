# frozen_string_literal: true

class ContactController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params).sanitize!

    if @contact.valid?
      ContactJob.perform_later(@contact.to_json)

      render 'thanks'
    elsif @contact.errors[:body].include?('is spam')
      render 'thanks'
    else
      flash.now[:error] = helpers.error_messages_for(@contact)

      render 'new', status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :phone_number, :subject, :body)
  end
end
