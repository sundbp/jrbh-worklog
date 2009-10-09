require 'test_helper'

class WorkPeriodsControllerTest < ActionController::TestCase

  test "should create work_period" do
    WorkPeriod.any_instance.expects(:save).returns(true)
    post :create, :work_period => { }
    assert_response :redirect
  end

  test "should handle failure to create work_period" do
    WorkPeriod.any_instance.expects(:save).returns(false)
    post :create, :work_period => { }
    assert_template "new"
  end

  test "should destroy work_period" do
    WorkPeriod.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => work_periods(:one).to_param
    assert_not_nil flash[:notice]    
    assert_response :redirect
  end

  test "should handle failure to destroy work_period" do
    WorkPeriod.any_instance.expects(:destroy).returns(false)    
    delete :destroy, :id => work_periods(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end

  test "should get edit for work_period" do
    get :edit, :id => work_periods(:one).to_param
    assert_response :success
  end

  test "should get index for work_periods" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_periods)
  end

  test "should get new for work_period" do
    get :new
    assert_response :success
  end

  test "should get show for work_period" do
    get :show, :id => work_periods(:one).to_param
    assert_response :success
  end

  test "should update work_period" do
    WorkPeriod.any_instance.expects(:save).returns(true)
    put :update, :id => work_periods(:one).to_param, :work_period => { }
    assert_response :redirect
  end

  test "should handle failure to update work_period" do
    WorkPeriod.any_instance.expects(:save).returns(false)
    put :update, :id => work_periods(:one).to_param, :work_period => { }
    assert_template "edit"
  end

end