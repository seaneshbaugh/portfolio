require "application_system_test_case"

class AssetsTest < ApplicationSystemTestCase
  test "public modules and fonts load locally without fetching admin code" do
    visit root_path

    assert_selector "body" do
      page.evaluate_script("typeof window.GLightbox === 'function'")
    end

    assert page.evaluate_async_script(<<~JS)
      const done = arguments[arguments.length - 1];
      document.fonts.load('24px "Material Icons"').then(fonts => done(fonts.length > 0), () => done(false));
    JS

    resources = page.evaluate_script("performance.getEntriesByType('resource').map(entry => new URL(entry.name).pathname)")

    assert resources.any? { |path| path.start_with?("/assets/") }
    assert_not resources.any? { |path| path.match?(%r{/assets/(ace/|controllers/|admin-)}) }

    imports = JSON.parse(find("script[type=importmap]", visible: :all).text(:all)).fetch("imports")

    assert imports.values.all? { |url| url.start_with?("/assets/") }
  end

  test "admin entrypoint connects editors without loading the public lightbox" do
    sign_in users(:sean_eshbaugh)

    visit new_admin_page_path

    assert_selector "#page_body-editor.ace_editor"
    assert_button "Insert Picture", disabled: false
    assert page.evaluate_script("typeof window.GLightbox === 'undefined'")
  end
end
