require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "valid company" do
    company = Company.new(name: "Acme Corp", website: "https://acme.com")
    assert company.valid?
  end

  test "requires name" do
    company = Company.new(website: "https://acme.com")
    assert_not company.valid?
    assert_includes company.errors[:name], "can't be blank"
  end

  test "website is optional" do
    company = Company.new(name: "Acme")
    assert company.valid?
  end

  test "to_s returns name" do
    company = Company.new(name: "Acme Corp")
    assert_equal "Acme Corp", company.to_s
  end
end
