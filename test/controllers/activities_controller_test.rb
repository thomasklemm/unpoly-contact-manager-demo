require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = Contact.create!(first_name: "Ada", last_name: "Lovelace", email: "ada.act2@example.com")
    @activity = @contact.activities.create!(kind: "note", body: "First note")
  end

  test "GET /contacts/:id/activities renders activities" do
    get contact_activities_path(@contact)
    assert_response :success
    assert_match "First note", response.body
  end

  test "POST /contacts/:id/activities creates activity" do
    assert_difference "@contact.activities.count", 1 do
      post contact_activities_path(@contact), params: {
        activity: { kind: "call", body: "Called today" }
      }
    end
    assert_redirected_to contact_activities_path(@contact)
  end

  test "POST /contacts/:id/activities with blank body re-renders" do
    assert_no_difference "@contact.activities.count" do
      post contact_activities_path(@contact), params: {
        activity: { kind: "email", body: "" }
      }
    end
    assert_response :unprocessable_entity
  end
end
