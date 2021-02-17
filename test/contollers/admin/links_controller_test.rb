# frozen_string_literal: true

require 'test_helper'

module Admin
  class LinksControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:sean_eshbaugh)
    end

    test 'should get links index' do
      get admin_links_url

      assert_response :ok
    end

    test 'should show a link' do
      link = links(:seaneshbaugh)

      get admin_link_url(link)

      assert_response :ok
    end

    test 'should not show a link that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get admin_link_url(id: 'does-not-exist')
      end
    end

    test 'should get a new link' do
      get new_admin_link_url

      assert_response :ok
    end

    test 'should get a link to edit' do
      link = links(:seaneshbaugh)

      get edit_admin_link_url(link)

      assert_response :ok
    end

    test 'should not get a link that does not exist to edit' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get edit_admin_link_url(id: 'does-not-exist')
      end
    end

    test 'should create a link' do
      assert_difference('Link.count', 1) do
        post admin_links_url, params: { link: { text: 'test', url: 'http://test.com/', description: 'this is a test', published_at: Time.zone.now.strftime('%Y-%m-%d'), visible: true } }
      end

      assert_response :see_other

      assert_redirected_to admin_link_path(Link.chronological.last)
    end

    test 'should not create an invalid link' do
      assert_no_difference('Link.count') do
        post admin_links_url, params: { link: { text: '' } }
      end

      assert_response :unprocessable_entity
    end

    test 'should update a link' do
      link = links(:seaneshbaugh)

      patch admin_link_url(link), params: { link: { text: 'Updated Link' } }

      link.reload

      assert_equal('Updated Link', link.text)

      assert_response :see_other

      assert_redirected_to edit_admin_link_path(link)

      assert_equal(I18n.t('admin.links.update.success'), flash[:success])
    end

    test 'should not update a link with invalid data' do
      link = links(:seaneshbaugh)

      patch admin_link_url(link), params: { link: { text: '' } }

      assert_response :unprocessable_entity
    end

    test 'should not update a link that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        patch admin_link_url(id: 'does-not-exist'), params: { link: { text: 'Does Not Exist', body: 'I have nothing to say.' } }
      end
    end

    test 'should destroy a link' do
      link = links(:seaneshbaugh)

      assert_difference('Link.count', -1) do
        delete admin_link_url(link)
      end

      assert_response :see_other

      assert_redirected_to admin_links_path
    end

    test 'should not destroy a link that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        delete admin_link_url(id: 'does-not-exist')
      end
    end
  end
end
