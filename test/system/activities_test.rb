require "application_system_test_case"

# ════════════════════════════════════════════════════════════════════════════
# GlobalActivitiesTest — /activities page
#
# Covers the clock-icon navigation button, day-grouped activity log,
# contact-name links, the "Log Activity" overlay, and its validation.
# ════════════════════════════════════════════════════════════════════════════

class GlobalActivitiesTest < ApplicationSystemTestCase
  setup do
    @alice      = contacts(:alice)       # has alice_note + alice_call fixtures
    @bob        = contacts(:bob)         # no activities
    @alice_note = activities(:alice_note)  # 2 days ago — note
    @alice_call = activities(:alice_call)  # 1 day ago — call
  end

  # ── 1. Navigation ────────────────────────────────────────────────────────

  test "clock icon in sidebar navigates to the activity log" do
    visit root_path
    demo_pause

    find("[title='Activity Log']").click
    wait_for_unpoly_idle
    demo_pause

    assert_current_path activities_path

    within "#contact-detail" do
      assert_text "Activity Log"
    end
  end

  test "navigating to activity log keeps the sidebar intact" do
    visit root_path

    find("[title='Activity Log']").click
    wait_for_unpoly_idle

    assert_selector "#contacts-sidebar"
    assert_selector "#contacts-list"
  end

  # ── 2. Activity list ─────────────────────────────────────────────────────

  test "activity log displays all activities across contacts" do
    visit activities_path
    demo_pause

    within "#global-activities" do
      assert_text @alice_note.body
      assert_text @alice_call.body
    end
  end

  test "each activity shows the contact's full name as a link" do
    visit activities_path

    within "#global-activities" do
      assert_link @alice.full_name
    end
  end

  test "activities include the kind label" do
    visit activities_path

    within "#global-activities" do
      assert_text "Note"   # alice_note
      assert_text "Call"   # alice_call
    end
  end

  test "activities are grouped under day headers" do
    visit activities_path
    demo_pause

    within "#global-activities" do
      assert_text /yesterday/i   # alice_call is 1.day.ago; header is CSS-uppercased
    end
  end

  test "empty state is shown when no activities exist" do
    Activity.delete_all
    visit activities_path

    within "#global-activities" do
      assert_text "No activities yet"
    end
  end

  # ── 3. Contact links ─────────────────────────────────────────────────────

  test "clicking a contact name from the activity log opens the contact detail" do
    visit activities_path
    demo_pause

    first_link = find_link(@alice.full_name, match: :first)
    first_link.click
    wait_for_unpoly_idle
    demo_pause

    within "#contact-detail" do
      assert_text @alice.full_name
      assert_text @alice.email
    end

    # Sidebar stays alive — only #contact-detail was replaced
    assert_selector "#contacts-sidebar"
  end

  # ── 4. Log Activity overlay ──────────────────────────────────────────────

  test "Log Activity button opens a modal overlay" do
    visit activities_path
    demo_pause

    click_link "Log Activity"
    demo_pause

    assert_selector "up-modal-box"
    within_modal do
      assert_text "Log Activity"
      assert_selector "select#activity_contact_id"
      assert_selector "textarea[name='activity[body]']"
    end
  end

  test "logging an activity from the overlay adds it to the list" do
    visit activities_path
    demo_pause

    click_link "Log Activity"
    assert_selector "up-modal-box"
    demo_pause

    within_modal do
      select @bob.full_name, from: "Contact"
      find("textarea[name='activity[body]']").set("Great introductory call with Bob.")
      demo_pause(0.8)
      click_button "Log Activity"
    end

    demo_pause

    # Overlay dismissed
    assert_no_selector "up-modal-box"

    # List refreshed — new activity is visible
    within "#global-activities" do
      assert_text "Great introductory call with Bob."
      assert_link @bob.full_name
    end

    # Persisted to the database
    assert Activity.find_by(body: "Great introductory call with Bob.")
  end

  test "submitting without a body shows a validation error and keeps the overlay open" do
    visit activities_path

    click_link "Log Activity"
    assert_selector "up-modal-box"

    within_modal do
      select @alice.full_name, from: "Contact"
      # Leave body blank
      click_button "Log Activity"

      assert_text "can't be blank"
    end

    # Overlay stays open for correction
    assert_selector "up-modal-box"
  end

  test "Cancel button dismisses the overlay without saving" do
    visit activities_path
    initial_count = Activity.count

    click_link "Log Activity"
    assert_selector "up-modal-box"

    within_modal do
      click_button "Cancel"
    end

    assert_no_selector "up-modal-box"
    assert_equal initial_count, Activity.count
  end

  # ── 5. Drawer mode ───────────────────────────────────────────────────────

  test "Log Activity opens as a drawer when drawer mode is active" do
    visit activities_path

    page.execute_script("toggleOverlayStyle()")

    click_link "Log Activity"

    assert_selector "up-drawer-box"
    assert_no_selector "up-modal-box"

    within_drawer do
      assert_text "Log Activity"
    end

    page.execute_script("toggleOverlayStyle()")  # restore
  end
end

# ════════════════════════════════════════════════════════════════════════════
# ActivitiesDirectNavigationTest — full-page URL access
#
# Verifies /activities and /activities/new work as standalone pages,
# independent of Unpoly fragment navigation.
# ════════════════════════════════════════════════════════════════════════════

class ActivitiesDirectNavigationTest < ApplicationSystemTestCase
  setup do
    @alice = contacts(:alice)
  end

  test "visiting /activities directly renders the full two-panel layout" do
    visit activities_path

    assert_selector "#contacts-sidebar"
    assert_selector "#contact-detail"
    assert_selector "#global-activities"
    assert_text "Activity Log"
  end

  test "visiting /activities/new directly renders the log activity form" do
    visit new_activity_path

    assert_no_selector "up-modal-box"
    assert_selector "form"
    assert_text "Log Activity"
    assert_selector "select#activity_contact_id"
  end
end
