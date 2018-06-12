require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  setup do
    sign_in users(:sean_eshbaugh)
  end

  test 'should get users index' do
    get :index

    assert_response :ok
  end

  test 'should show a user' do
    user = users(:casie_clark)

    get :show, params: { id: user }

    assert_response :ok
  end

  test 'should not show a user that does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 'does-not-exist' }
    end
  end

  test 'should get a new user' do
    get :new

    assert_response :ok
  end

  test 'should get a user to edit' do
    user = users(:casie_clark)

    get :edit, params: { id: user }

    assert_response :ok
  end

  test 'should not get a user that does not exist to edit' do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, params: { id: 'does-not-exist' }
    end
  end

  test 'should create a user' do
    assert_difference('User.count', 1) do
      post :create, params: { user: { email: 'newuser@seaneshbaugh.com', first_name: 'New', last_name: 'User', password: 'test123456', password_confirmation: 'test123456' } }
    end

    assert_response :see_other

    assert_redirected_to admin_user_path(User.chronological.last)
  end

  test 'should not create an invalid user' do
    assert_no_difference('User.count') do
      post :create, params: { user: { email: '' } }
    end

    assert_response :unprocessable_entity
  end

  test 'should update a user' do
    user = users(:casie_clark)

    patch :update, params: { id: user, user: { email: 'updateduser@seaneshbaugh.com' } }

    user.reload

    assert user.email == 'updateduser@seaneshbaugh.com'

    assert_response :see_other

    assert_redirected_to edit_admin_user_path(user)

    assert_equal I18n.t('admin.users.update.success'), flash[:success]
  end

  test 'should not update a user with invalid data' do
    user = users(:casie_clark)

    patch :update, params: { id: user, user: { email: '' } }

    assert_response :unprocessable_entity
  end

  test 'should not update a user that does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      patch :update, params: { id: 'does-not-exist', user: { email: 'doesnotexist@seaneshbaugh.com' } }
    end
  end

  test 'should destroy a user' do
    user = users(:casie_clark)

    assert_difference('User.count', -1) do
      delete :destroy, params: { id: user }
    end

    assert_response :see_other

    assert_redirected_to admin_users_path
  end

  test 'should not destroy a user that does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      delete :destroy, params: { id: 'does-not-exist' }
    end
  end
end
