require "application_system_test_case"

# ════════════════════════════════════════════════════════════════════════════
# ContactsTest — Unpoly interaction patterns
#
# Each test exercises one or more of the 15 Unpoly features documented in
# the README. Run with a visible browser to use as a live demo:
#
#   DEMO_MODE=1 bin/rails test:system
#
# All tests also run headlessly in CI.
# ════════════════════════════════════════════════════════════════════════════

class ContactsTest < ApplicationSystemTestCase
  setup do
    @alice    = contacts(:alice)            # starred, Customer + VIP tags, has activities
    @bob      = contacts(:bob)              # not starred, Prospect tag, at Globex
    @carol    = contacts(:carol)            # starred, at Acme, no activities
    @archived = contacts(:archived_contact) # archived
  end

  # ── 1. Initial load ─────────────────────────────────────────────────────────
  # The two-panel layout: sidebar + empty right panel placeholder.

  test "contacts list loads on root path" do
    visit root_path
    demo_pause

    within "#contacts-sidebar" do
      assert_text @alice.full_name
      assert_text @bob.full_name
      assert_text @carol.full_name
      assert_no_text @archived.full_name   # archived hidden in default All view
    end

    within "#contact-detail" do
      assert_text "Select a contact"
    end
  end

  # ── 2. Fragment update (Feature 1) ───────────────────────────────────────────
  # up-target="#contact-detail" + up-history="true" + up-instant + up-preload
  # Only the right panel replaces; sidebar stays intact.

  test "clicking a contact updates only the right panel — fragment update" do
    visit root_path
    demo_pause

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end
    demo_pause

    within "#contact-detail" do
      assert_text @alice.full_name
      assert_text @alice.email
      assert_text @alice.phone
      assert_text @alice.company.name
    end

    # Sidebar still intact — only #contact-detail was replaced
    within "#contacts-sidebar" do
      assert_text @bob.full_name
      assert_text @carol.full_name
    end
  end

  test "clicking a contact updates the browser URL — up-history" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end

    assert_current_path contact_path(@alice)
  end

  test "clicking a second contact replaces the detail panel again" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end
    demo_pause(0.8)

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end
    demo_pause(0.8)

    within "#contact-detail" do
      assert_text @bob.full_name
      assert_no_text @alice.full_name
    end
  end

  test "clicking a contact marks its sidebar row as active — up-nav" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end

    assert_selector "#contact-row-#{@alice.id}.up-current"
  end

  # ── 3. Live search (Feature 5) ──────────────────────────────────────────────
  # up-autosubmit + up-watch-delay="300" on the search input.
  # Only #contacts-list updates; search box keeps focus (up-focus="keep").

  test "live search filters the contact list as you type — up-autosubmit" do
    visit root_path
    demo_pause

    fill_in "q", with: "Alice"
    demo_pause

    within "#contacts-list" do
      assert_text @alice.full_name
      assert_no_text @bob.full_name
      assert_no_text @carol.full_name
    end

    # Clear search — full list restores
    fill_in "q", with: ""
    demo_pause

    within "#contacts-list" do
      assert_text @alice.full_name
      assert_text @bob.full_name
    end
  end

  test "search by company name finds matching contacts" do
    visit root_path

    fill_in "q", with: "Globex"

    within "#contacts-list" do
      assert_text @bob.full_name        # Bob is at Globex
      assert_no_text @alice.full_name   # Alice is at Acme
    end
  end

  test "search preserves focus in the search box — up-focus='keep'" do
    visit root_path

    # Click explicitly so Chrome registers a real user-initiated focus event,
    # giving Unpoly's up-focus="keep" something to restore after the fragment swap.
    find_field("q").click
    find_field("q").send_keys("Bob")

    within "#contacts-list" do
      assert_text @bob.full_name
    end

    # Wait for Unpoly to finish restoring focus via up-focus="keep".
    wait_for_unpoly_idle
    focused_id = page.evaluate_script("document.activeElement.id")
    assert_equal "q", focused_id
  end

  # ── 4. Filter tabs (Feature 4 — URL alias + fragment update) ─────────────────
  # Each tab replaces #contacts-list. The active tab is highlighted via up-alias.

  test "Starred filter shows only starred contacts" do
    visit root_path
    demo_pause

    within "#contacts-list" do
      click_link "Starred"
    end
    demo_pause

    within "#contacts-list" do
      assert_text @alice.full_name    # starred
      assert_text @carol.full_name    # starred
      assert_no_text @bob.full_name   # not starred
    end
  end

  test "Archived filter shows only archived contacts" do
    visit root_path
    demo_pause

    within "#contacts-list" do
      click_link "Archived"
    end
    demo_pause

    within "#contacts-list" do
      assert_text @archived.full_name
      assert_no_text @alice.full_name
      assert_no_text @bob.full_name
    end
  end

  test "filter tabs cycle All → Starred → Archived → All" do
    visit root_path

    within "#contacts-list" do
      assert_text @alice.full_name
      assert_text @bob.full_name
      assert_no_text @archived.full_name

      click_link "Starred"
    end
    within "#contacts-list" do
      assert_text @alice.full_name
      assert_no_text @bob.full_name

      click_link "Archived"
    end
    within "#contacts-list" do
      assert_text @archived.full_name
      assert_no_text @alice.full_name

      click_link "All"
    end
    within "#contacts-list" do
      assert_text @alice.full_name
      assert_text @bob.full_name
    end
  end

  test "search with no results shows the empty state" do
    visit root_path

    fill_in "q", with: "zzznomatch"

    within "#contacts-list" do
      assert_text "No contacts found"
    end
  end

  test "search and filter tabs compose — search within Starred" do
    visit root_path

    within "#contacts-list" do
      click_link "Starred"
    end

    fill_in "q", with: "Alice"

    within "#contacts-list" do
      assert_text @alice.full_name
      assert_no_text @carol.full_name   # Carol is starred but doesn't match "Alice"
    end
  end

  # ── 5. Sort options ──────────────────────────────────────────────────────────

  test "sort by First name reorders the contact list" do
    visit root_path

    within "#contacts-list" do
      click_link "First"
    end

    within "#contacts-list" do
      assert_text @alice.full_name
      assert_text @bob.full_name
    end
  end

  test "sort by Company orders contacts by company name" do
    visit root_path

    within "#contacts-list" do
      click_link "Company"
    end
    wait_for_unpoly_idle

    # Alice and Carol (Acme Corp) should appear before Bob (Globex Industries)
    names_in_order = page.all("#contacts-list .contact-name").map(&:text)
    alice_pos = names_in_order.index(@alice.full_name)
    bob_pos   = names_in_order.index(@bob.full_name)
    assert alice_pos < bob_pos,
      "Expected Alice (Acme) to appear before Bob (Globex) when sorted by company"
  end

  test "sort by Name orders contacts alphabetically by last name" do
    visit root_path

    within "#contacts-list" do
      click_link "Name"
    end
    wait_for_unpoly_idle

    # Davis < Johnson < Williams alphabetically
    names_in_order = page.all("#contacts-list .contact-name").map(&:text)
    carol_pos = names_in_order.index(@carol.full_name)
    alice_pos = names_in_order.index(@alice.full_name)
    assert carol_pos < alice_pos,
      "Expected Carol Davis to appear before Alice Johnson when sorted by last name"
  end

  # ── 6. New contact modal (Feature 6) ────────────────────────────────────────
  # data-overlay-link macro → up-layer="new modal"
  # up-on-accepted renders new contact in right panel + reloads list.

  test "New button opens a modal overlay" do
    visit root_path
    demo_pause

    click_link "New"
    demo_pause

    assert_selector "up-modal-box"
    within_modal do
      assert_text "New Contact"
      assert_selector "form"
    end
  end

  test "creating a contact via modal closes the modal and shows the new contact" do
    visit root_path
    click_link "New"
    assert_selector "up-modal-box"
    demo_pause

    within_modal do
      fill_form_field "First name", "Zara"
      fill_form_field "Last name",  "Newby"
      fill_form_field "Email",      "zara.newby@example.com"
      fill_form_field "Phone",      "+1-555-9999"
      demo_pause(0.8)
      settle_form
      click_button "Create Contact"
    end

    demo_pause

    # Modal closed after successful save
    assert_no_selector "up-modal-box"

    # Flash confirms creation — use assert_selector (not within) so Capybara
    # re-queries the DOM after up-hungry replaces the #flash element.
    assert_selector "#flash", text: "Zara Newby was added"

    # New contact appears in the sidebar list
    within "#contacts-list" do
      assert_text "Zara Newby"
    end

    # And is shown selected in the right panel
    within "#contact-detail" do
      assert_text "Zara Newby"
    end
  end

  test "Cancel button dismisses the modal without creating a contact" do
    visit root_path
    initial_count = Contact.count

    click_link "New"
    assert_selector "up-modal-box"

    within_modal do
      fill_form_field "First name", "Temp"
      click_button "Cancel"
    end

    assert_no_selector "up-modal-box"
    assert_equal initial_count, Contact.count
  end

  # ── 7. Per-field validation (Feature 8) ──────────────────────────────────────
  # up-validate="" on the form tag.
  # On blur, the server re-renders the form with inline errors.

  test "submitting the new contact form with blank fields shows validation errors" do
    visit root_path
    click_link "New"
    assert_selector "up-modal-box"
    demo_pause

    within_modal do
      click_button "Create Contact"   # submit with all fields blank
      assert_text "can't be blank"    # inline error
    end

    # Modal stays open for correction
    assert_selector "up-modal-box"
  end

  test "up-validate shows per-field errors on blur — leaving email blank" do
    visit root_path
    click_link "New"
    assert_selector "up-modal-box"

    within_modal do
      # Make the email field "dirty" by typing then clearing, then blur.
      # An unmodified (never-typed) field doesn't fire a change event on blur,
      # so up-validate wouldn't trigger for a pristine empty field.
      find_field("Email").set("x")   # type — marks field as dirty
      find_field("Email").set("")    # clear — value is now blank but changed
      find_field("Phone").click      # blur email → change event → up-validate fires

      # Email was blank when it blurred → inline validation error
      assert_text "can't be blank"
    end
  end

  # ── 8. Edit contact modal (Feature 7) ────────────────────────────────────────
  # Same overlay pattern as new — but up-on-accepted reloads #contact-info
  # instead of navigating to a new URL.

  test "Edit button opens the contact form in a modal" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end

    within "#contact-detail" do
      click_link "Edit"
    end

    assert_selector "up-modal-box"
    within_modal do
      assert_text "Edit Contact"
      assert_field "First name", with: @alice.first_name
    end
  end

  test "editing a contact via modal updates the detail panel — no full reload" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end
    demo_pause(0.8)

    within "#contact-detail" do
      click_link "Edit"
    end

    assert_selector "up-modal-box"
    demo_pause(0.8)

    within_modal do
      fill_form_field "First name", "Alicia"
      demo_pause(0.8)
      click_button "Save Changes"
    end

    demo_pause

    assert_no_selector "up-modal-box"

    within "#contact-detail" do
      assert_text "Alicia Johnson"
    end

    within "#contacts-sidebar" do
      assert_text "Alicia Johnson"
    end
  end

  test "flash appears after editing a contact" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      click_link "Edit"
    end

    within_modal do
      fill_form_field "First name", "Bobby"
      click_button "Save Changes"
    end

    assert_selector "#flash", text: "Bobby Williams was updated"
  end

  test "submitting the edit form with a blank first name shows a validation error" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      click_link "Edit"
    end

    assert_selector "up-modal-box"

    within_modal do
      find_field("First name").set("")
      settle_form     # blank blur → up-validate → server re-renders with error
      click_button "Save Changes"

      assert_text "can't be blank"
    end

    assert_selector "up-modal-box"         # overlay stays open for correction
    assert_equal "Bob", @bob.reload.first_name  # unchanged in DB
  end

  test "Cancel in the edit modal keeps the original contact data" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      click_link "Edit"
    end

    within_modal do
      fill_form_field "First name", "Changed"
      click_button "Cancel"
    end

    assert_no_selector "up-modal-box"
    assert_equal "Bob", @bob.reload.first_name  # unchanged in DB
  end

  # ── 9. Reactive company select (Feature 9) ───────────────────────────────────
  # up-watch + up-target="#company-fields" on the company select.
  # Changing the selection triggers a server round-trip that re-renders
  # the dependent #company-fields fragment.

  test "changing the company selection triggers a reactive fragment update" do
    visit root_path
    click_link "New"
    assert_selector "up-modal-box"

    within_modal do
      select "Acme Corp", from: "Company"
      wait_for_unpoly_idle   # up-watch re-renders #company-fields

      select "Globex Industries", from: "Company"
      wait_for_unpoly_idle   # second re-render completes without error
    end

    # No crash — reactive select handled both changes
    assert_selector "up-modal-box"
  end

  # ── 10. Nested subinteraction (Feature 10) ───────────────────────────────────
  # "+ New company" inside the contact form opens a second modal on top.
  # Creating the company closes the inner modal and injects the new
  # company option into the parent form's select — without re-rendering
  # the outer contact form.

  test "create a company from within the contact form — nested modal" do
    visit root_path
    click_link "New"
    assert_selector "up-modal-box"
    demo_pause(0.8)

    within_modal do
      fill_form_field "First name", "Nested"
      fill_form_field "Last name",  "User"
      fill_form_field "Email",      "nested.user@example.com"
    end

    # Open the nested company modal
    within_modal do
      click_link "+ New company"
    end
    demo_pause(0.8)

    # Wait for the nested company modal to open (minimum: 2 waits until
    # at least two up-modal-box elements exist, then picks the last one).
    nested_modals = page.all("up-modal-box", minimum: 2)
    within nested_modals.last do
      fill_in "Name",    with: "Nested Corp"
      fill_in "Website", with: "https://nested.example.com"
      demo_pause(0.8)
      click_button "Create Company"
    end

    demo_pause(0.8)

    # Inner modal closed; outer contact form still open
    assert_selector "up-modal-box"

    # Company was created in the database
    assert Company.find_by(name: "Nested Corp"), "Expected Nested Corp to be created"

    # The new company option was injected into the contact form's select
    within_modal do
      assert_selector "option", text: "Nested Corp"
    end
  end

  # ── 11. Lazy loading (Feature 11) ────────────────────────────────────────────
  # up-defer + up-href on #activities-panel.
  # The panel renders with a spinner, then loads the timeline in a
  # separate request after the main panel is displayed.

  test "activity timeline lazy-loads after the main contact panel — up-defer" do
    visit root_path
    demo_pause

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end

    # Capybara waits automatically for the deferred content to appear
    within "#contact-detail" do
      within "#activities-panel" do
        assert_text "Discussed pricing"       # alice_note fixture
        assert_text "30-minute intro call"    # alice_call fixture
      end
    end
  end

  test "adding an activity updates the panel in-place" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end

    # Wait for lazy load
    within "#activities-panel" do
      assert_text "Discussed pricing"
    end
    demo_pause(0.8)

    within "#activities-panel" do
      find("textarea[name='activity[body]']").set("Follow-up scheduled for next week.")
      demo_pause(0.8)
      click_button "Log Activity"
    end

    demo_pause

    within "#activities-panel" do
      assert_text "Follow-up scheduled for next week."
    end
  end

  test "activities panel for a contact with no activities shows the empty state" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#activities-panel" do
      assert_text "No activity yet"
    end
  end

  # ── 12. Optimistic star toggle (Feature 12) ──────────────────────────────────
  # up-preview="toggle-star" toggles the class immediately.
  # Server confirms; if it fails, Unpoly rolls back.

  test "star button toggles immediately — optimistic UI" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name   # Bob starts unstarred
    end
    demo_pause(0.8)

    within "#contact-detail" do
      star_btn = find("button.star-icon.unstarred")
      star_btn.click
      demo_pause(0.8)
      assert_selector "button.star-icon.starred"
    end

    assert @bob.reload.starred?
  end

  test "star can be toggled back to unstarred" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      find("button.star-icon.unstarred").click
      demo_pause(0.8)
      assert_selector "button.star-icon.starred"

      find("button.star-icon.starred").click
      demo_pause(0.8)
      assert_selector "button.star-icon.unstarred"
    end

    assert_not @bob.reload.starred?
  end

  test "starring a contact makes it appear in the Starred filter" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      find("button.star-icon.unstarred").click
    end

    wait_for_unpoly_idle

    within "#contacts-list" do
      click_link "Starred"
    end

    within "#contacts-list" do
      assert_text @bob.full_name
    end
  end

  # ── 13. Optimistic archive (Feature 13) ──────────────────────────────────────
  # up-preview="archive-contact" fades the row immediately.
  # Confirmation dialog → server archives → list and detail both refresh.

  test "archiving a contact removes it from the active list" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end
    demo_pause(0.8)

    within "#contact-detail" do
      accept_confirm "Archive #{@bob.full_name}?" do
        click_button "Archive"
      end
    end
    demo_pause

    assert_selector "#flash", text: "was archived"

    within "#contacts-list" do
      assert_no_text @bob.full_name
    end

    assert @bob.reload.archived?
  end

  test "unarchiving a contact restores it to the active list" do
    visit root_path

    within "#contacts-list" do
      click_link "Archived"
    end

    within "#contacts-sidebar" do
      click_link @archived.full_name
    end
    demo_pause(0.8)

    within "#contact-detail" do
      click_button "Unarchive"   # no confirm dialog for unarchive
    end
    demo_pause

    assert_selector "#flash", text: "was unarchived"

    within "#contacts-list" do
      click_link "All"
    end

    within "#contacts-list" do
      assert_text @archived.full_name
    end

    assert_not @archived.reload.archived?
  end

  test "dismissing the archive confirmation keeps the contact in the list" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      dismiss_confirm "Archive #{@bob.full_name}?" do
        click_button "Archive"
      end
    end

    within "#contacts-list" do
      assert_text @bob.full_name
    end

    assert_not @bob.reload.archived?
  end

  # ── 14. Delete with confirmation ────────────────────────────────────────────

  test "deleting a contact removes it from the list" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end
    demo_pause(0.8)

    within "#contact-detail" do
      accept_confirm "Delete #{@bob.full_name}? This cannot be undone." do
        click_button "Delete"
      end
    end
    demo_pause

    assert_selector "#flash", text: "Contact was deleted"

    within "#contacts-list" do
      assert_no_text @bob.full_name
    end

    assert_nil Contact.find_by(id: @bob.id)
  end

  test "cancelling the delete confirmation keeps the contact" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      dismiss_confirm "Delete #{@bob.full_name}? This cannot be undone." do
        click_button "Delete"
      end
    end

    within "#contacts-sidebar" do
      assert_text @bob.full_name
    end

    assert Contact.find_by(id: @bob.id)
  end

  # ── 15. Hungry flash messages (Feature 14) ──────────────────────────────────
  # #flash[up-hungry] — appears after any mutation, even mid-fragment-update.

  test "flash message appears after creating a new contact — up-hungry" do
    visit root_path
    click_link "New"
    assert_selector "up-modal-box"

    within_modal do
      fill_form_field "First name", "Flash"
      fill_form_field "Last name",  "Test"
      fill_form_field "Email",      "flash.test@example.com"
      settle_form
      click_button "Create Contact"
    end

    assert_selector "#flash", text: "Flash Test was added"
  end

  test "flash message appears after archiving a contact" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      accept_confirm { click_button "Archive" }
    end

    assert_selector "#flash", text: "was archived"
  end

  test "flash message appears after deleting a contact" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @bob.full_name
    end

    within "#contact-detail" do
      accept_confirm { click_button "Delete" }
    end

    assert_selector "#flash", text: "Contact was deleted"
  end

  # ── 16. Company link opens in a modal ───────────────────────────────────────
  # The company name in the detail panel uses up-layer="new modal".

  test "company name in the detail panel opens company profile in a modal" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end

    within "#contact-detail" do
      click_link @alice.company.name
    end

    assert_selector "up-modal-box"
    within_modal do
      assert_text @alice.company.name
    end
  end

  # ── 17. Contact detail content ──────────────────────────────────────────────
  # Tags, notes, and the archived badge are rendered from the model.

  test "tags are displayed in the contact detail panel" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name   # Alice has Customer + VIP tags
    end

    within "#contact-detail" do
      assert_text "Customer"
      assert_text "VIP"
    end
  end

  test "notes are displayed in the contact detail panel" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name   # Alice has notes fixture text
    end

    within "#contact-detail" do
      assert_text "Met at the 2024 SaaS Summit."
    end
  end

  test "archived badge is shown for archived contacts" do
    visit contact_path(@archived)

    within "#contact-detail" do
      assert_text "Archived"
    end
  end

  # ── 18. Drawer overlay mode ──────────────────────────────────────────────────
  # The Settings toggle switches the data-overlay-link macro between
  # up-layer="new modal" and up-layer="new drawer".

  test "switching to drawer mode opens overlays as a drawer" do
    visit root_path

    # toggleOverlayStyle() switches from the default 'modal' → 'drawer'
    page.execute_script("toggleOverlayStyle()")
    demo_pause(0.8)

    click_link "New"
    demo_pause

    assert_selector "up-drawer-box"
    assert_no_selector "up-modal-box"

    within_drawer do
      assert_text "New Contact"
    end

    # Restore modal mode for subsequent tests
    page.execute_script("toggleOverlayStyle()")
  end
end

# ════════════════════════════════════════════════════════════════════════════
# ContactsDirectNavigationTest — full-page URL access
#
# Verifies that every URL works as a standalone page (not just as an Unpoly
# fragment). These tests simulate a user arriving via a bookmark or a hard
# refresh, where Unpoly renders the full two-panel layout from scratch.
# ════════════════════════════════════════════════════════════════════════════

class ContactsDirectNavigationTest < ApplicationSystemTestCase
  setup do
    @alice = contacts(:alice)
    @bob   = contacts(:bob)
  end

  test "visiting /contacts renders the full two-panel layout" do
    visit contacts_path

    assert_selector "#contacts-sidebar"
    assert_selector "#contact-detail"
    assert_text @alice.full_name
    assert_text @bob.full_name
  end

  test "visiting a contact URL directly shows the full layout with that contact selected" do
    visit contact_path(@alice)

    assert_selector "#contacts-sidebar"

    within "#contact-detail" do
      assert_text @alice.full_name
      assert_text @alice.email
    end

    # The sidebar is also populated
    within "#contacts-sidebar" do
      assert_text @bob.full_name
    end
  end

  test "visiting /contacts/new directly renders a full-page form (not a modal)" do
    visit new_contact_path

    # No modal — the form is the full page
    assert_no_selector "up-modal-box"
    assert_selector "form"
    assert_text "New Contact"
    assert_selector "input[name='contact[first_name]']"
  end

  test "submitting /contacts/new directly creates a contact and redirects to it" do
    visit new_contact_path

    fill_form_field "First name", "Direct"
    fill_form_field "Last name",  "Create"
    fill_form_field "Email",      "direct.create@example.com"
    settle_form
    click_button "Create Contact"
    wait_for_unpoly_idle  # wait for Unpoly's AJAX navigation to complete

    contact = Contact.find_by(email: "direct.create@example.com")
    assert contact, "Expected contact to be created"
    assert_current_path contact_path(contact)
  end

  test "visiting /contacts/:id/edit directly renders the edit form" do
    visit edit_contact_path(@alice)

    assert_selector "form"
    assert_text "Edit Contact"
    assert_field "First name", with: @alice.first_name
    assert_field "Last name",  with: @alice.last_name
  end

  test "submitting the edit form directly updates the contact and redirects" do
    visit edit_contact_path(@alice)

    fill_form_field "First name", "Alicia"
    settle_form
    click_button "Save Changes"
    wait_for_unpoly_idle  # wait for Unpoly's AJAX navigation to complete

    assert_equal "Alicia", @alice.reload.first_name
    assert_current_path contact_path(@alice)
  end

  test "visiting /contacts?filter=starred shows only starred contacts" do
    visit contacts_path(filter: "starred")

    within "#contacts-list" do
      assert_text @alice.full_name     # starred
      assert_no_text @bob.full_name    # not starred
    end
  end

  test "visiting /contacts?q=Bob shows only matching contacts" do
    visit contacts_path(q: "Bob")

    within "#contacts-list" do
      assert_text @bob.full_name
      assert_no_text @alice.full_name
    end
  end
end
