require 'test_helper'

class CompaniesControllerTest < ActionController::TestCase

  test "should create company" do
    Company.any_instance.expects(:save).returns(true)
    post :create, :company => { }
    assert_response :redirect
  end

  test "should handle failure to create company" do
    Company.any_instance.expects(:save).returns(false)
    post :create, :company => { }
    assert_template "new"
  end

  test "should destroy company" do
    Company.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => companies(:one).to_param
    assert_not_nil flash[:notice]    
    assert_response :redirect
  end

  test "should handle failure to destroy company" do
    Company.any_instance.expects(:destroy).returns(false)    
    delete :destroy, :id => companies(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end

  test "should get edit for company" do
    get :edit, :id => companies(:one).to_param
    assert_response :success
  end

  test "should get index for companies" do
    get :index
    assert_response :success
    assert_not_nil assigns(:companies)
  end

  test "should get new for company" do
    get :new
    assert_response :success
  end

  test "should get show for company" do
    get :show, :id => companies(:one).to_param
    assert_response :success
  end

  test "should update company" do
    Company.any_instance.expects(:save).returns(true)
    put :update, :id => companies(:one).to_param, :company => { }
    assert_response :redirect
  end

  test "should handle failure to update company" do
    Company.any_instance.expects(:save).returns(false)
    put :update, :id => companies(:one).to_param, :company => { }
    assert_template "edit"
  end

end