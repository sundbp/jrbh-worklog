require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase

  test "should create user_session" do
    UserSession.any_instance.expects(:save).returns(true)
    post :create, :user_session => { }
    assert_response :redirect
  end

  test "should handle failure to create user_session" do
    UserSession.any_instance.expects(:save).returns(false)
    post :create, :user_session => { }
    assert_template "new"
  end

  test "should destroy user_session" do
    UserSession.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => user_sessions(:one).to_param
    assert_not_nil flash[:notice]    
    assert_response :redirect
  end

  test "should handle failure to destroy user_session" do
    UserSession.any_instance.expects(:destroy).returns(false)    
    delete :destroy, :id => user_sessions(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end

  test "should get edit for user_session" do
    get :edit, :id => user_sessions(:one).to_param
    assert_response :success
  end

  test "should get index for user_sessions" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_sessions)
  end

  test "should get new for user_session" do
    get :new
    assert_response :success
  end

  test "should get show for user_session" do
    get :show, :id => user_sessions(:one).to_param
    assert_response :success
  end

  test "should update user_session" do
    UserSession.any_instance.expects(:save).returns(true)
    put :update, :id => user_sessions(:one).to_param, :user_session => { }
    assert_response :redirect
  end

  test "should handle failure to update user_session" do
    UserSession.any_instance.expects(:save).returns(false)
    put :update, :id => user_sessions(:one).to_param, :user_session => { }
    assert_template "edit"
  end

end