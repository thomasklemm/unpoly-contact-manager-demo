require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  test "GET /companies/new renders form" do
    get new_company_path
    assert_response :success
    assert_select "form"
  end

  test "POST /companies creates company and redirects" do
    assert_difference "Company.count", 1 do
      post companies_path, params: { company: { name: "NewCo", website: "https://newco.com" } }
    end
    assert_redirected_to companies_path
  end

  test "POST /companies with blank name re-renders form" do
    assert_no_difference "Company.count" do
      post companies_path, params: { company: { name: "" } }
    end
    assert_response :unprocessable_entity
  end
end
