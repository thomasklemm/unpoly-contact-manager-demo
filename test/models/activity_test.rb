require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  setup do
    @contact = Contact.create!(first_name: "Ada", last_name: "Lovelace", email: "ada.act@example.com")
  end

  test "valid activity" do
    activity = Activity.new(contact: @contact, kind: "note", body: "Had a great call.")
    assert activity.valid?
  end

  test "requires body" do
    activity = Activity.new(contact: @contact, kind: "note")
    assert_not activity.valid?
    assert_includes activity.errors[:body], "can't be blank"
  end

  test "validates kind inclusion" do
    activity = Activity.new(contact: @contact, kind: "tweet", body: "Something")
    assert_not activity.valid?
    assert activity.errors[:kind].any?
  end

  test "all valid kinds are accepted" do
    Activity::KINDS.each do |kind|
      activity = Activity.new(contact: @contact, kind: kind, body: "Text")
      assert activity.valid?, "Expected #{kind} to be valid"
    end
  end

  test "kind_icon returns emoji for call" do
    activity = Activity.new(kind: "call")
    assert_equal "📞", activity.kind_icon
  end

  test "kind_icon returns emoji for email" do
    activity = Activity.new(kind: "email")
    assert_equal "✉️", activity.kind_icon
  end

  test "kind_icon returns emoji for note" do
    activity = Activity.new(kind: "note")
    assert_equal "📝", activity.kind_icon
  end
end
