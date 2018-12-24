# frozen_string_literal: true

require 'test_helper'

class ContactControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test 'should enqueue a new ContactJob with valid parameters' do
    assert_enqueued_jobs 1, only: ContactJob do
      post contact_url, params: { contact: { name: 'Test Contact', email: 'test@test.com', phone_number: '+1 214-123-4567', subject: 'Hello!', body: 'This is a test.' } }
    end

    assert_response :ok
  end

  test 'should not enqueue a new ContactJob with invalid parameters' do
    assert_no_enqueued_jobs do
      post contact_url, params: { contact: { name: '', email: 'test@test.com', phone_number: '+1 214-123-4567', subject: 'Hello!', body: 'This is a test.' } }
    end

    assert_response :unprocessable_entity
  end
end
