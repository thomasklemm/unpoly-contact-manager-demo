require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact  = contacts(:alice)
    @activity = activities(:alice_note)
  end

  # ── Per-contact index ────────────────────────────────────────────────────────

  test "GET /contacts/:id/activities renders the activities panel" do
    get contact_activities_path(@contact)
    assert_response :success
    assert_match @activity.body, response.body
  end

  test "GET /contacts/:id/activities with kind param filters by kind" do
    get contact_activities_path(@contact), params: { kind: "note" }
    assert_response :success
    assert_match @activity.body, response.body
  end

  test "GET /contacts/:id/activities with kind=call hides notes" do
    get contact_activities_path(@contact), params: { kind: "call" }
    assert_response :success
    assert_no_match @activity.body, response.body
  end

  test "POST /contacts/:id/activities creates activity" do
    assert_difference "@contact.activities.count", 1 do
      post contact_activities_path(@contact), params: {
        activity: { kind: "call", body: "Called today" }
      }
    end
    assert_redirected_to contact_activities_path(@contact)
  end

  test "POST /contacts/:id/activities with blank body re-renders with error" do
    assert_no_difference "@contact.activities.count" do
      post contact_activities_path(@contact), params: {
        activity: { kind: "email", body: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  # ── Global index ─────────────────────────────────────────────────────────────

  test "GET /activities renders the global activity log" do
    get activities_path
    assert_response :success
    assert_match "Activity Log", response.body
    assert_match @activity.body, response.body
  end

  test "GET /activities filters by q param" do
    get activities_path, params: { q: "pricing" }
    assert_response :success
    assert_match activities(:alice_note).body, response.body
    assert_no_match activities(:alice_call).body, response.body
  end

  test "GET /activities filters by kind param" do
    get activities_path, params: { kind: "note" }
    assert_response :success
    assert_match activities(:alice_note).body, response.body
    assert_no_match activities(:alice_call).body, response.body
  end

  test "GET /activities with empty results renders empty state" do
    Activity.delete_all
    get activities_path
    assert_response :success
    assert_match "No activities yet", response.body
  end

  # ── Show ─────────────────────────────────────────────────────────────────────

  test "GET /activities/:id renders the activity detail" do
    get activity_path(@activity)
    assert_response :success
    assert_match @activity.body, response.body
    assert_match @contact.full_name, response.body
  end

  # ── Edit ─────────────────────────────────────────────────────────────────────

  test "GET /activities/:id/edit renders the edit form" do
    get edit_activity_path(@activity)
    assert_response :success
    assert_match "Edit Activity", response.body
    assert_match @activity.body, response.body
  end

  # ── Update ───────────────────────────────────────────────────────────────────

  test "PATCH /activities/:id updates and redirects to activities" do
    patch activity_path(@activity), params: { activity: { kind: "call", body: "Updated note." } }
    assert_redirected_to activities_path
    assert_equal "Updated note.", @activity.reload.body
  end

  test "PATCH /activities/:id in an overlay accepts the layer" do
    patch activity_path(@activity),
      params: { activity: { kind: "call", body: "Overlay update." } },
      headers: { "X-Up-Version" => "3.0.0", "X-Up-Mode" => "modal" }
    assert_response :no_content
    assert_equal "Overlay update.", @activity.reload.body
  end

  test "PATCH /activities/:id with blank body re-renders the edit form" do
    patch activity_path(@activity), params: { activity: { kind: "note", body: "" } }
    assert_response :unprocessable_entity
  end

  # ── Destroy ──────────────────────────────────────────────────────────────────

  test "DELETE /activities/:id destroys and redirects to activities" do
    assert_difference "Activity.count", -1 do
      delete activity_path(@activity)
    end
    assert_redirected_to activities_path
  end

  test "DELETE /activities/:id in an overlay accepts the layer" do
    assert_difference "Activity.count", -1 do
      delete activity_path(@activity),
        headers: { "X-Up-Version" => "3.0.0", "X-Up-Mode" => "modal" }
    end
    assert_response :no_content
  end

  test "DELETE /activities/:id targeting #activities-panel redirects to contact activities" do
    assert_difference "Activity.count", -1 do
      delete activity_path(@activity),
        headers: { "X-Up-Version" => "3.0.0", "X-Up-Target" => "#activities-panel" }
    end
    assert_response :redirect
    assert_equal contact_activities_path(@contact), URI.parse(response.location).path
  end
end
