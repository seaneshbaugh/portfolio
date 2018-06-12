require 'test_helper'

class Admin::PagesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:sean_eshbaugh)
  end

  test 'should get pages index' do
    get :index

    assert_response 200
  end

  test 'should show a page' do
    page = pages(:about)

    get :show, params: { id: page }

    assert_response 200
  end

  test 'should not show a page that does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 'does-not-exist' }
    end
  end

  test 'should get a new page' do
    get :new

    assert_response 200
  end

  test 'should get a page to edit' do
    page = pages(:about)

    get :edit, params: { id: page }

    assert_response 200
  end

  test 'should not get a page that does not exist to edit' do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, params: { id: 'does-not-exist' }
    end
  end

  test 'should create a page' do
    assert_difference('Page.count', 1) do
      post :create, params: { page: { title: 'New Page', body: 'Testing 1 2 3' } }
    end

    assert_redirected_to admin_page_path(Page.chronological.last)
  end

  test 'should not create an invalid page' do
    assert_no_difference('Page.count') do
      post :create, params: { page: { title: '' } }
    end

    assert_response 422
  end

  test 'should update a page' do
    page = pages(:about)

    patch :update, params: { id: page, page: { title: 'Updated Page' } }

    page.reload

    assert page.title == 'Updated Page'

    assert_redirected_to edit_admin_page_path(page)

    assert_equal I18n.t('admin.pages.update.success'), flash[:success]
  end

  test 'should not update a page with invalid data' do
    page = pages(:about)

    patch :update, params: { id: page, page: { title: '' } }

    assert_response 422
  end

  test 'should not update a page that does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      patch :update, params: { id: 'does-not-exist', page: { title: 'Does Not Exist', body: 'Page intentionally left blank.' } }
    end
  end

  test 'should destroy a page' do
    page = pages(:about)

    assert_difference('Page.count', -1) do
      delete :destroy, params: { id: page }
    end

    assert_redirected_to admin_pages_path
  end

  test 'should not destroy a page that does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      delete :destroy, params: { id: 'does-not-exist' }
    end
  end
end
