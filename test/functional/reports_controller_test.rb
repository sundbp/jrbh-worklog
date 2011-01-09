require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  test "should get utilization_summary" do
    get :utilization_summary
    assert_response :success
  end

  test "should get individual_summary" do
    get :individual_summary
    assert_response :success
  end

  test "should get company_summary" do
    get :company_summary
    assert_response :success
  end

end
