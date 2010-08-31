require 'test_helper'

class CalculatorsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:calculators)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create calculator" do
    assert_difference('Calculator.count') do
      post :create, :calculator => { }
    end

    assert_redirected_to calculator_path(assigns(:calculator))
  end

  test "should show calculator" do
    get :show, :id => calculators(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => calculators(:one).to_param
    assert_response :success
  end

  test "should update calculator" do
    put :update, :id => calculators(:one).to_param, :calculator => { }
    assert_redirected_to calculator_path(assigns(:calculator))
  end

  test "should destroy calculator" do
    assert_difference('Calculator.count', -1) do
      delete :destroy, :id => calculators(:one).to_param
    end

    assert_redirected_to calculators_path
  end
end
