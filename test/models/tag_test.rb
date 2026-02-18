require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "valid tag" do
    tag = Tag.new(name: "VIP", color: "#6e4ca6")
    assert tag.valid?
  end

  test "requires name" do
    tag = Tag.new(color: "#6e4ca6")
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "requires color" do
    tag = Tag.new(name: "VIP")
    assert_not tag.valid?
    assert_includes tag.errors[:color], "can't be blank"
  end

  test "to_s returns name" do
    tag = Tag.new(name: "Partner")
    assert_equal "Partner", tag.to_s
  end
end
