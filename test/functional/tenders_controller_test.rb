require 'test_helper'

class TendersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tenders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tender" do
    assert_difference('Tender.count') do
      post :create, :tender => { }
    end

    assert_redirected_to tender_path(assigns(:tender))
  end

  test "should show tender" do
    get :show, :id => tenders(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => tenders(:one).to_param
    assert_response :success
  end

  test "should update tender" do
    put :update, :id => tenders(:one).to_param, :tender => { }
    assert_redirected_to tender_path(assigns(:tender))
  end

  test "should destroy tender" do
    assert_difference('Tender.count', -1) do
      delete :destroy, :id => tenders(:one).to_param
    end

    assert_redirected_to tenders_path
  end
end
