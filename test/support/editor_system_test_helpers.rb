module EditorSystemTestHelpers
  # Change Ace rather than the hidden Rails textarea: this also exercises the
  # editor's onChange synchronization with the submitted field.
  def fill_in_ace(field, with:)
    editor = find("##{field}-editor .ace_editor")
    # Ace's typing assistance automatically closes HTML tags and brackets.
    # Its public setValue API loads exact source while still firing onChange.
    editor.execute_script("this.env.editor.setValue(arguments[0], -1)", with)
    assert_field field, with: with, visible: :all
  end

  def select_picture(picture, button: "Insert Picture")
    click_button button
    within ".picture-selector-modal" do
      find(".picture-selector-modal-picture", text: picture.title).click
    end
    assert_no_selector ".picture-selector-modal"
  end
end
