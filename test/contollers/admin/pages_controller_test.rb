# frozen_string_literal: true

require 'test_helper'

module Admin
  class PagesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:sean_eshbaugh)
    end

    test 'should get pages index' do
      get admin_pages_url

      assert_response :ok
    end

    test 'should show a page' do
      page = pages(:about)

      get admin_page_url(page)

      assert_response :ok
    end

    test 'should not show a page that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get admin_page_url(id: 'does-not-exist')
      end
    end

    test 'should get a new page' do
      get new_admin_page_url

      assert_response :ok
    end

    test 'should get a page to edit' do
      page = pages(:about)

      get edit_admin_page_url(page)

      assert_response :ok
    end

    test 'should not get a page that does not exist to edit' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get edit_admin_page_url(id: 'does-not-exist')
      end
    end

    test 'should create a page' do
      assert_difference('Page.count', 1) do
        post admin_pages_url, params: { page: { title: 'New Page', body: 'Testing 1 2 3' } }
      end

      assert_response :see_other

      assert_redirected_to admin_page_path(Page.chronological.last)
    end

    test 'should not create an invalid page' do
      assert_no_difference('Page.count') do
        post admin_pages_url, params: { page: { title: '' } }
      end

      assert_response :unprocessable_entity
    end

    test 'should update a page' do
      page = pages(:about)

      patch admin_page_url(page), params: { page: { title: 'Updated Page' } }

      page.reload

      assert page.title == 'Updated Page'

      assert_response :see_other

      assert_redirected_to edit_admin_page_path(page)

      assert_equal I18n.t('admin.pages.update.success'), flash[:success]
    end

    test 'should not update a page with invalid data' do
      page = pages(:about)

      patch admin_page_url(page), params: { page: { title: '' } }

      assert_response :unprocessable_entity
    end

    test 'should not update a page that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        patch admin_page_url(id: 'does-not-exist'), params: { page: { title: 'Does Not Exist', body: 'Page intentionally left blank.' } }
      end
    end

    test 'should destroy a page' do
      page = pages(:about)

      assert_difference('Page.count', -1) do
        delete admin_page_url(page)
      end

      assert_response :see_other

      assert_redirected_to admin_pages_path
    end

    test 'should not destroy a page that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        delete admin_page_url(id: 'does-not-exist')
      end
    end
  end
end
