require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "valid contact" do
    contact = Contact.new(first_name: "Ada", last_name: "Lovelace", email: "ada@example.com")
    assert contact.valid?
  end

  test "requires first_name" do
    contact = Contact.new(last_name: "Lovelace", email: "ada@example.com")
    assert_not contact.valid?
    assert_includes contact.errors[:first_name], "can't be blank"
  end

  test "requires last_name" do
    contact = Contact.new(first_name: "Ada", email: "ada@example.com")
    assert_not contact.valid?
    assert_includes contact.errors[:last_name], "can't be blank"
  end

  test "requires email" do
    contact = Contact.new(first_name: "Ada", last_name: "Lovelace")
    assert_not contact.valid?
    assert_includes contact.errors[:email], "can't be blank"
  end

  test "validates email format" do
    contact = Contact.new(first_name: "Ada", last_name: "Lovelace", email: "not-an-email")
    assert_not contact.valid?
    assert contact.errors[:email].any?
  end

  test "validates email uniqueness" do
    Contact.create!(first_name: "Ada", last_name: "Lovelace", email: "ada@example.com")
    duplicate = Contact.new(first_name: "Ada2", last_name: "Lovelace2", email: "ada@example.com")
    assert_not duplicate.valid?
    assert contact_errors_include?(duplicate, :email)
  end

  test "full_name returns concatenated name" do
    contact = Contact.new(first_name: "Ada", last_name: "Lovelace")
    assert_equal "Ada Lovelace", contact.full_name
  end

  test "active scope excludes archived contacts" do
    active  = Contact.create!(first_name: "A", last_name: "B", email: "active@x.com")
    archived = Contact.create!(first_name: "C", last_name: "D", email: "arch@x.com", archived_at: 1.day.ago)
    assert_includes Contact.active, active
    assert_not_includes Contact.active, archived
  end

  test "starred scope returns only starred, non-archived contacts" do
    star    = Contact.create!(first_name: "A", last_name: "B", email: "star@x.com", starred: true)
    nostar  = Contact.create!(first_name: "C", last_name: "D", email: "nostar@x.com", starred: false)
    assert_includes Contact.starred, star
    assert_not_includes Contact.starred, nostar
  end

  test "archived scope returns archived contacts" do
    archived = Contact.create!(first_name: "A", last_name: "B", email: "arch2@x.com", archived_at: 1.hour.ago)
    active   = Contact.create!(first_name: "C", last_name: "D", email: "act2@x.com")
    assert_includes Contact.archived, archived
    assert_not_includes Contact.archived, active
  end

  test "archived? returns true when archived_at is set" do
    contact = Contact.new(archived_at: Time.current)
    assert contact.archived?
  end

  test "archived? returns false when archived_at is nil" do
    contact = Contact.new
    assert_not contact.archived?
  end

  private

  def contact_errors_include?(contact, field)
    contact.errors[field].any?
  end
end
