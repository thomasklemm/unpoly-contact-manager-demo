require "application_system_test_case"

# ════════════════════════════════════════════════════════════════════════════
# CompaniesTest — companies list and company detail
#
# Covers navigation to the companies screen, the list view, fragment
# updates when clicking a company row, the New Company modal, and the
# subinteraction where a contact link inside a company modal shatters
# back to the root layer.
# ════════════════════════════════════════════════════════════════════════════

class CompaniesTest < ApplicationSystemTestCase
  setup do
    @acme   = companies(:acme)
    @globex = companies(:globex)
    @alice  = contacts(:alice)    # active, at Acme
    @bob    = contacts(:bob)      # active, at Globex
    @carol  = contacts(:carol)    # active, at Acme
  end

  # ── 1. Navigation ────────────────────────────────────────────────────────

  test "companies icon in the sidebar navigates to the companies list" do
    visit root_path
    demo_pause

    find("[title='Companies']").click
    demo_pause

    assert_current_path companies_path

    within "#contact-detail" do
      assert_text "Companies"
    end
  end

  test "navigating to companies keeps the sidebar intact" do
    visit root_path

    find("[title='Companies']").click

    assert_selector "#contacts-sidebar"
    assert_selector "#contacts-list"
  end

  # ── 2. Companies list ────────────────────────────────────────────────────

  test "companies list shows all companies" do
    visit companies_path
    demo_pause

    within "#contact-detail" do
      assert_text @acme.name
      assert_text @globex.name
    end
  end

  test "each company row shows the contact count" do
    visit companies_path

    within "#contact-detail" do
      # Acme: Alice + Carol; Globex: Bob + archived_contact
      assert_text "2 contacts", count: 2
    end
  end

  # ── 3. Fragment update ───────────────────────────────────────────────────

  test "clicking a company row updates only the right panel — sidebar stays" do
    visit companies_path
    demo_pause

    within "#contact-detail" do
      click_link @acme.name
    end
    demo_pause

    within "#contact-detail" do
      assert_text @acme.name
      assert_text @alice.full_name
      assert_text @carol.full_name
    end

    # Sidebar still intact — only #contact-detail was replaced
    assert_selector "#contacts-sidebar"
    assert_selector "#contacts-list"
  end

  # ── 4. Company detail ────────────────────────────────────────────────────

  test "company detail shows only active contacts — archived are excluded" do
    visit company_path(@globex)
    demo_pause

    within "#contact-detail" do
      assert_text @bob.full_name                           # active
      assert_no_text contacts(:archived_contact).full_name # archived, not shown
    end
  end

  # ── 5. New Company modal ─────────────────────────────────────────────────

  test "New Company button opens a modal overlay" do
    visit companies_path
    demo_pause

    click_link "New Company"
    demo_pause

    assert_selector "up-modal-box"
    within_modal do
      assert_text "New Company"
      assert_selector "input[name='company[name]']"
    end
  end

  test "creating a company via the modal adds it to the list" do
    visit companies_path

    click_link "New Company"
    assert_selector "up-modal-box"
    demo_pause

    within_modal do
      fill_in "Name",    with: "Initech"
      fill_in "Website", with: "https://initech.example.com"
      demo_pause(0.8)
      click_button "Create Company"
    end

    demo_pause

    assert_no_selector "up-modal-box"

    within "#contact-detail" do
      assert_text "Initech"
    end

    assert Company.find_by(name: "Initech")
  end

  test "submitting a blank name shows a validation error" do
    visit companies_path

    click_link "New Company"
    assert_selector "up-modal-box"

    within_modal do
      click_button "Create Company"   # name is blank
      assert_text "can't be blank"
    end

    assert_selector "up-modal-box"   # overlay stays open for correction
  end

  test "Cancel button dismisses the modal without creating a company" do
    visit companies_path
    initial_count = Company.count

    click_link "New Company"
    assert_selector "up-modal-box"

    within_modal do
      fill_in "Name", with: "Temp Corp"
      click_button "Cancel"
    end

    assert_no_selector "up-modal-box"
    assert_equal initial_count, Company.count
  end

  # ── 6. Contact link shatters the overlay ────────────────────────────────
  # The company modal opens from the contact detail panel. Clicking a
  # contact inside it uses up-layer="root", closing the modal and
  # rendering the contact in the root layer's #contact-detail.

  test "clicking a contact in the company modal navigates to that contact" do
    visit root_path

    within "#contacts-sidebar" do
      click_link @alice.full_name
    end
    demo_pause(0.8)

    within "#contact-detail" do
      click_link @acme.name    # opens Acme profile in a modal
    end

    assert_selector "up-modal-box"
    demo_pause

    within_modal do
      click_link @alice.full_name    # up-layer="root" — renders into root layer
    end
    demo_pause

    assert_no_selector "up-modal-box"   # modal dismissed

    within "#contact-detail" do
      assert_text @alice.full_name
      assert_text @alice.email
    end
  end
end

# ════════════════════════════════════════════════════════════════════════════
# CompaniesDirectNavigationTest — full-page URL access
#
# Verifies that companies URLs work as standalone pages without Unpoly
# fragment navigation.
# ════════════════════════════════════════════════════════════════════════════

class CompaniesDirectNavigationTest < ApplicationSystemTestCase
  setup do
    @acme  = companies(:acme)
    @alice = contacts(:alice)
  end

  test "visiting /companies renders the full two-panel layout" do
    visit companies_path

    assert_selector "#contacts-sidebar"
    assert_selector "#contact-detail"
    assert_text "Companies"
    assert_text @acme.name
  end

  test "visiting a company URL directly renders the full layout with that company" do
    visit company_path(@acme)

    assert_selector "#contacts-sidebar"

    within "#contact-detail" do
      assert_text @acme.name
      assert_text @alice.full_name
    end
  end

  test "visiting /companies/new directly renders a full-page form" do
    visit new_company_path

    assert_no_selector "up-modal-box"
    assert_selector "form"
    assert_text "New Company"
    assert_selector "input[name='company[name]']"
  end
end
