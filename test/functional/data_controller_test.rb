require 'test_helper'

class DataControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create datum" do
    assert_difference('Datum.count') do
      post :create, :datum => { }
    end

    assert_redirected_to datum_path(assigns(:datum))
  end

  test "should show datum" do
    get :show, :id => data(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => data(:one).to_param
    assert_response :success
  end

  test "should update datum" do
    put :update, :id => data(:one).to_param, :datum => { }
    assert_redirected_to datum_path(assigns(:datum))
  end

  test "should destroy datum" do
    assert_difference('Datum.count', -1) do
      delete :destroy, :id => data(:one).to_param
    end

    assert_redirected_to data_path
  end
end
