require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(name: "TestCo")
    @contact = Contact.create!(
      first_name: "Ada",
      last_name: "Lovelace",
      email: "ada@testco.example.com",
      company: @company
    )
  end

  # --- index ---

  test "GET /contacts renders contacts list" do
    get contacts_path
    assert_response :success
    assert_select "#contacts-list"
    assert_select "#contact-detail"
  end

  test "GET /contacts filters by search query" do
    Contact.create!(first_name: "Charles", last_name: "Babbage", email: "charles@example.com")
    get contacts_path, params: { q: "Ada" }
    assert_response :success
    assert_match "Ada", response.body
    assert_no_match "Babbage", response.body
  end

  test "GET /contacts with filter=starred shows only starred" do
    starred = Contact.create!(first_name: "Star", last_name: "Man", email: "star@example.com", starred: true)
    regular = Contact.create!(first_name: "Normal", last_name: "Person", email: "normal@example.com")
    get contacts_path, params: { filter: "starred" }
    assert_response :success
    assert_match "Star", response.body
    assert_no_match "Normal", response.body
  end

  test "GET /contacts with filter=archived shows only archived" do
    archived = Contact.create!(first_name: "Arch", last_name: "Man", email: "arch@example.com", archived_at: 1.day.ago)
    active   = Contact.create!(first_name: "Active", last_name: "Person", email: "activep@example.com")
    get contacts_path, params: { filter: "archived" }
    assert_response :success
    assert_match "Arch", response.body
    assert_no_match "Active", response.body
  end

  # --- show ---

  test "GET /contacts/:id shows contact detail" do
    get contact_path(@contact)
    assert_response :success
    assert_match "Ada Lovelace", response.body
  end

  # --- new ---

  test "GET /contacts/new renders form" do
    get new_contact_path
    assert_response :success
    assert_select "form"
  end

  # --- create ---

  test "POST /contacts creates contact and redirects" do
    assert_difference "Contact.count", 1 do
      post contacts_path, params: { contact: {
        first_name: "Grace",
        last_name: "Hopper",
        email: "grace@navy.example.com"
      } }
    end
    assert_redirected_to contact_path(Contact.last)
  end

  test "POST /contacts with invalid params re-renders form" do
    assert_no_difference "Contact.count" do
      post contacts_path, params: { contact: { first_name: "", last_name: "", email: "bad" } }
    end
    assert_response :unprocessable_entity
  end

  # --- edit ---

  test "GET /contacts/:id/edit renders form" do
    get edit_contact_path(@contact)
    assert_response :success
    assert_select "form"
  end

  # --- update ---

  test "PATCH /contacts/:id updates contact" do
    patch contact_path(@contact), params: { contact: { first_name: "Updated" } }
    assert_redirected_to contact_path(@contact)
    assert_equal "Updated", @contact.reload.first_name
  end

  test "PATCH /contacts/:id with invalid params re-renders form" do
    patch contact_path(@contact), params: { contact: { email: "" } }
    assert_response :unprocessable_entity
  end

  # --- destroy ---

  test "DELETE /contacts/:id destroys contact" do
    assert_difference "Contact.count", -1 do
      delete contact_path(@contact)
    end
    assert_redirected_to contacts_path
  end

  # --- star ---

  test "PATCH /contacts/:id/star toggles starred" do
    assert_not @contact.starred?
    patch star_contact_path(@contact)
    assert @contact.reload.starred?
    patch star_contact_path(@contact)
    assert_not @contact.reload.starred?
  end

  # --- archive ---

  test "PATCH /contacts/:id/archive toggles archived_at" do
    assert_not @contact.archived?
    patch archive_contact_path(@contact)
    assert @contact.reload.archived?
    patch archive_contact_path(@contact)
    assert_not @contact.reload.archived?
  end
end
