require 'test_helper'

class PriviledgesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:priviledges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create priviledge" do
    assert_difference('Priviledge.count') do
      post :create, :priviledge => { }
    end

    assert_redirected_to priviledge_path(assigns(:priviledge))
  end

  test "should show priviledge" do
    get :show, :id => priviledges(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => priviledges(:one).to_param
    assert_response :success
  end

  test "should update priviledge" do
    put :update, :id => priviledges(:one).to_param, :priviledge => { }
    assert_redirected_to priviledge_path(assigns(:priviledge))
  end

  test "should destroy priviledge" do
    assert_difference('Priviledge.count', -1) do
      delete :destroy, :id => priviledges(:one).to_param
    end

    assert_redirected_to priviledges_path
  end
end
