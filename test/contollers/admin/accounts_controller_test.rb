# frozen_string_literal: true

require 'test_helper'

module Admin
  class AccountsControllerTest < ActionController::TestCase
    setup do
      sign_in users(:sean_eshbaugh)
    end

    test 'should get account show' do
      get :show

      assert_response :ok
    end

    test 'should get account edit' do
      get :edit

      assert_response :ok
    end

    test "should update the current user's account" do
      user = users(:sean_eshbaugh)

      patch :update, params: { account: { email: 'updateduser@seaneshbaugh.com' } }

      user.reload

      assert user.email == 'updateduser@seaneshbaugh.com'

      assert_response :see_other

      assert_redirected_to admin_account_path

      assert_equal I18n.t('admin.accounts.update.success'), flash[:success]
    end

    test 'should not update the current user with invalid data' do
      patch :update, params: { account: { email: '' } }

      assert_response :unprocessable_entity
    end
  end
end
