require 'test_helper'

class WorklogTasksControllerTest < ActionController::TestCase

  test "should create worklog_task" do
    WorklogTask.any_instance.expects(:save).returns(true)
    post :create, :worklog_task => { }
    assert_response :redirect
  end

  test "should handle failure to create worklog_task" do
    WorklogTask.any_instance.expects(:save).returns(false)
    post :create, :worklog_task => { }
    assert_template "new"
  end

  test "should destroy worklog_task" do
    WorklogTask.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => worklog_tasks(:one).to_param
    assert_not_nil flash[:notice]    
    assert_response :redirect
  end

  test "should handle failure to destroy worklog_task" do
    WorklogTask.any_instance.expects(:destroy).returns(false)    
    delete :destroy, :id => worklog_tasks(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end

  test "should get edit for worklog_task" do
    get :edit, :id => worklog_tasks(:one).to_param
    assert_response :success
  end

  test "should get index for worklog_tasks" do
    get :index
    assert_response :success
    assert_not_nil assigns(:worklog_tasks)
  end

  test "should get new for worklog_task" do
    get :new
    assert_response :success
  end

  test "should get show for worklog_task" do
    get :show, :id => worklog_tasks(:one).to_param
    assert_response :success
  end

  test "should update worklog_task" do
    WorklogTask.any_instance.expects(:save).returns(true)
    put :update, :id => worklog_tasks(:one).to_param, :worklog_task => { }
    assert_response :redirect
  end

  test "should handle failure to update worklog_task" do
    WorklogTask.any_instance.expects(:save).returns(false)
    put :update, :id => worklog_tasks(:one).to_param, :worklog_task => { }
    assert_template "edit"
  end

end