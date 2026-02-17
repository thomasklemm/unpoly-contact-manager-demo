require "application_system_test_case"

class ContactsTest < ApplicationSystemTestCase
  setup do
    @alice = contacts(:alice)
    @bob = contacts(:bob)
    @carol = contacts(:carol)
    @archived = contacts(:archived_contact)
  end

  # ── 1. Contacts list loads on root path ────────────────────────────────

  test "contacts list loads on root path" do
    visit root_path

    within "#contacts-sidebar" do
      assert_text @alice.full_name
      assert_text @bob.full_name
      assert_text @carol.full_name
      # Archived contacts should NOT appear in the default "All" view
      assert_no_text @archived.full_name
    end

    # Right panel shows placeholder
    within "#contact-detail" do
      assert_text "Select a contact"
    end
  end

  # ── 2. Clicking a contact updates only #contact-detail ─────────────────

  test "clicking a contact shows detail in right panel" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end

    within "#contact-detail" do
      assert_text @alice.full_name
      assert_text @alice.email
      assert_text @alice.phone
      assert_text @alice.company.name
    end

    # Sidebar should still be visible (fragment update, not full reload)
    within "#contacts-sidebar" do
      assert_text @bob.full_name
    end
  end

  # ── 3. Live search filters the contact list ────────────────────────────

  test "live search filters contacts" do
    visit root_path

    fill_in "q", with: "Alice"

    # Wait for autosubmit to update the list
    within "#contacts-list" do
      assert_text @alice.full_name
      assert_no_text @bob.full_name
    end

    # Clear search to restore full list
    fill_in "q", with: ""

    within "#contacts-list" do
      assert_text @alice.full_name
      assert_text @bob.full_name
    end
  end

  # ── 4. "+ New Contact" opens a modal ───────────────────────────────────

  test "new contact link opens a modal" do
    visit root_path

    click_link "New Contact"

    # Unpoly modal should appear
    assert_selector "up-modal-box"
    within "up-modal-box" do
      assert_text "New Contact"
      assert_selector "form"
    end
  end

  # ── 5. Creating a contact via modal ────────────────────────────────────

  test "creating a contact via modal closes modal and refreshes list" do
    visit root_path

    click_link "New Contact"
    assert_selector "up-modal-box"

    within "up-modal-box" do
      fill_in "First name", with: "Zara"
      fill_in "Last name", with: "Newby"
      fill_in "Email", with: "zara.newby@example.com"
      fill_in "Phone", with: "+1-555-9999"
      click_button "Create Contact"
    end

    # Modal should close
    assert_no_selector "up-modal-box"

    # Flash notice should appear
    within "#flash" do
      assert_text "Zara Newby was added"
    end

    # New contact should appear in the list
    within "#contacts-list" do
      assert_text "Zara Newby"
    end
  end

  # ── 6. Editing a contact via modal ─────────────────────────────────────

  test "editing a contact via modal closes modal and refreshes detail" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end

    within "#contact-detail" do
      assert_text @alice.full_name
      click_link "Edit"
    end

    assert_selector "up-modal-box"

    within "up-modal-box" do
      fill_in "First name", with: "Alicia"
      click_button "Save Changes"
    end

    # Modal should close
    assert_no_selector "up-modal-box"

    # Detail panel should show updated name
    within "#contact-detail" do
      assert_text "Alicia Johnson"
    end
  end

  # ── 7. Star toggle ────────────────────────────────────────────────────

  test "star toggle works" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      assert_text @bob.full_name

      # Bob is not starred — click the star button
      star_button = find("button.star-icon")
      assert_match(/unstarred/, star_button[:class])
      star_button.click

      # After toggling, the star should be starred
      assert_selector "button.star-icon.starred"
    end

    # Verify in database
    assert @bob.reload.starred?
  end

  # ── 8. Archive / Unarchive ─────────────────────────────────────────────

  test "archiving and unarchiving a contact works" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      assert_text @bob.full_name

      # Accept the confirmation dialog for archiving
      accept_confirm "Archive #{@bob.full_name}?" do
        click_button "Archive"
      end
    end

    # Flash should confirm archival
    within "#flash" do
      assert_text "was archived"
    end

    # Bob should no longer be in the active contacts list
    within "#contacts-list" do
      assert_no_text @bob.full_name
    end

    # Now view archived contacts
    within "#contacts-list" do
      click_link "Archived"
    end

    within "#contacts-list" do
      assert_text @bob.full_name
    end

    # Click Bob in archived list
    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      # Unarchive — no confirmation dialog for unarchive
      click_button "Unarchive"
    end

    within "#flash" do
      assert_text "was unarchived"
    end
  end

  # ── 9. Delete with confirmation ────────────────────────────────────────

  test "deleting a contact removes it from the list" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      assert_text @bob.full_name

      accept_confirm "Delete #{@bob.full_name}? This cannot be undone." do
        click_button "Delete"
      end
    end

    # Bob should be gone from the list
    within "#contacts-list" do
      assert_no_text @bob.full_name
    end

    # Verify in database
    assert_nil Contact.find_by(id: @bob.id)
  end

  # ── 10. Filter tabs (Starred / Archived) ───────────────────────────────

  test "filter tabs switch between All, Starred, and Archived" do
    visit root_path

    # Default: All (active contacts)
    within "#contacts-list" do
      assert_text @alice.full_name
      assert_text @bob.full_name
      assert_no_text @archived.full_name
    end

    # Starred
    within "#contacts-list" do
      click_link "Starred"
    end

    within "#contacts-list" do
      assert_text @alice.full_name  # Alice is starred
      assert_no_text @bob.full_name  # Bob is not starred
    end

    # Archived
    within "#contacts-list" do
      click_link "Archived"
    end

    within "#contacts-list" do
      assert_text @archived.full_name
      assert_no_text @alice.full_name
    end

    # Back to All
    within "#contacts-list" do
      click_link "All"
    end

    within "#contacts-list" do
      assert_text @alice.full_name
      assert_text @bob.full_name
    end
  end
end
