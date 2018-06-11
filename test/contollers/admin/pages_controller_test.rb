require 'test_helper'

class Admin::PagesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:sean_eshbaugh)
  end

  test 'should get index' do
    get :index

    assert_response 200
  end

  test 'should get new' do
    get :new

    assert_response 200
  end

  test 'should create page' do
    assert_difference('Page.count') do
      post :create, params: { page: { title: 'New Page', body: 'Testing 1 2 3' } }
    end

    assert_redirected_to admin_page_path(Page.chronological.last)
  end

  test 'should not create invalid page' do
    assert_no_difference('Page.count') do
      post :create, params: { page: { title: '' } }
    end

    assert_response 422
  end

  test 'should show page' do
    page = pages(:about)

    get :show, params: { id: page }

    assert_response 200
  end

  test 'should get edit' do
    page = pages(:about)

    get :edit, params: { id: page }

    assert_response 200
  end

  test 'should update page' do
    page = pages(:about)

    patch :update, params: { id: page, page: { title: 'Updated Page' } }

    page.reload

    assert_redirected_to edit_admin_page_path(page)

    assert page.title == 'Updated Page'
  end

  test 'should not update page with invalid data' do
    page = pages(:about)

    patch :update, params: { id: page, page: { title: '' } }

    assert_response 422
  end

  test 'should destroy page' do
    page = pages(:about)

    assert_difference('Page.count', -1) do
      delete :destroy, params: { id: page }
    end

    assert_redirected_to admin_pages_path
  end

  test 'should not destroy a page that does not exist' do
    invalid_id = Page.pluck(:id).sort.last + 1

    assert_raises(ActiveRecord::RecordNotFound) do
      delete :destroy, params: { id: invalid_id }
    end
  end
end
