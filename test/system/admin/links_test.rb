require "application_system_test_case"
require_relative "../../support/editor_system_test_helpers"
require_relative "../../support/anonymous_browser_helpers"

module Admin
  class LinksTest < ApplicationSystemTestCase
    include EditorSystemTestHelpers
    include AnonymousBrowserHelpers

    setup { sign_in users(:sean_eshbaugh) }

    test "a blank date preserves the edited link until correction and its saved C++ tag is usable publicly" do
      record = links(:seaneshbaugh)

      record.update!(tag_list: "original-link")
      original_attributes = record.attributes.slice(*Link.column_names)
      original_tags = record.tags.order(:name).pluck(:name)
      draft = {
        text: "Recovered C++ reference",
        url: "https://example.test/recovered-link",
        description: "<p>A C++ reference kept after correcting its date.</p>",
        tags: "C++, recovered-links"
      }

      visit edit_admin_link_path(record)

      assert_field "link_published_at", with: record.published_at.to_date.iso8601

      fill_in "Text", with: draft[:text]
      fill_in "link_url", with: draft[:url]
      fill_in_ace "link_description", with: draft[:description]
      fill_in "link_tag_list", with: draft[:tags]
      fill_in "link_published_at", with: ""

      click_button "Submit"

      assert_text "Published At can't be blank"
      assert_equal original_attributes, record.reload.attributes.slice(*Link.column_names)
      assert_equal original_tags, record.tags.order(:name).pluck(:name)
      assert_link_draft draft, date: ""

      fill_in "link_published_at", with: "2021-02-14"

      click_button "Submit"

      assert_text "Link was successfully updated."
      assert_current_path edit_admin_link_path(record)

      saved = Link.find(record.id)

      assert_equal draft.values_at(:text, :url, :description), saved.attributes.values_at("text", "url", "description")
      assert_equal Date.new(2021, 2, 14), saved.published_at.to_date
      assert_equal [ "C++", "recovered-links" ], saved.tag_list.sort

      visit edit_admin_link_path(saved)

      assert_link_draft draft, date: "2021-02-14"

      with_anonymous_browser do
        visit links_path

        assert_no_selector "body.logged-in"

        click_link "2021", exact: true

        assert_current_path "/links/2021"

        click_link "February", exact: true

        assert_current_path "/links/2021/2"
        assert_link draft[:text], href: draft[:url]

        control = links(:cowboythecowdog)

        assert_link control.text, href: control.url

        within ".links" do
          click_link "C++", exact: true
        end

        assert_current_path links_path(tag: "C++")
        assert_selector ".links li.link", count: 1
        assert_link draft[:text], href: draft[:url]
        assert_no_link control.text, href: control.url
        assert_text "A C++ reference kept after correcting its date."
      end
    end

    test "create edit and delete a link" do
      visit new_admin_link_path

      fill_in "Text", with: "Browser link"
      fill_in "link_url", with: "https://example.test/browser"
      fill_in_ace "link_description", with: "<p>Browser description.</p>"
      fill_in "link_tag_list", with: "browser-link"
      fill_in "link_published_at", with: "2021-02-09"

      click_button "Submit"

      saved = Link.find_by!(text: "Browser link")

      assert_current_path admin_link_path(saved)

      assert_equal "<p>Browser description.</p>", saved.description
      assert_equal Date.new(2021, 2, 9), saved.published_at.to_date
      assert_includes saved.tag_list, "browser-link"

      visit edit_admin_link_path(saved)

      fill_in "Text", with: "Updated browser link"

      click_button "Submit"

      assert_current_path edit_admin_link_path(saved)
      assert_equal "Updated browser link", saved.reload.text

      visit admin_link_path(saved)

      accept_confirm { click_link "Delete" }

      assert_current_path admin_links_path
      assert_not Link.exists?(saved.id)
    end

    private

    def assert_link_draft(draft, date:)
      assert_field "link_text", with: draft[:text]
      assert_field "link_url", with: draft[:url]
      assert_field "link_description", with: draft[:description], visible: :all

      assert_selector "#link_description-editor.ace_editor" do |editor|
        editor.evaluate_script("this.env.editor.getValue()") == draft[:description]
      end

      parser = ActsAsTaggableOn.default_parser

      assert_equal parser.new(draft[:tags]).parse.sort, parser.new(find_field("link_tag_list").value).parse.sort
      assert_field "link_published_at", with: date
    end
  end
end
