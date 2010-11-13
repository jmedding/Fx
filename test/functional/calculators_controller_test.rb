require 'test_helper'
require "authlogic/test_case"

class CalculatorsControllerTest < ActionController::TestCase
  
  self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures/functional")
	fixtures :data
	fixtures :conversions
	fixtures :currencies
	
  test "should get index" do
    get :index
    assert_response :redirect
    assert_not_nil assigns(:calculators)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create calculator" do
    calc1 = create_test_calc("EUR", "USD", 60)
    #p calc1.inspect
    assert_equal 5.79973, calc1.provision
    calc2 = create_test_calc("USD", "EUR", 60)
    #p calc2.inspect
    assert_equal 5.4818, calc2.provision
    assert_redirected_to calculator_path(assigns(:calculator))
    
    #test case calc is invalid. Should redirect to :new
    post :create, :calculator => { :from => "EUR",  :to => "EUR", :duration => 60}
    assert_response :success  #render :new
    assert_template :new
  end

  test "should show calculator" do
    calc1 = create_test_calc("EUR", "USD", 60)
    get :show, :id => calc1.id
    assert_response :success
  end

  test "should get edit" do
    calc1 = create_test_calc("EUR", "USD", 60)
    get :edit, :id => calc1.id
    assert_response :success
  end

  test "should update calculator" do
    calc1 = create_test_calc("EUR", "USD", 60)
    put :update, :id => calc1.id, :calculator => {:duration => 90 }
    assert_redirected_to calculator_path(assigns(:calculator))
  end

  test "should destroy calculator" do
    calc1 = create_test_calc("EUR", "USD", 60)
    assert_difference('Calculator.count', -1) do
      delete :destroy, :id => calc1.id
    end

    assert_redirected_to calculators_path
  end
  
  def create_test_calc(c_in, c_out, duration)
    assert_difference('Calculator.count') do
      post :create, :calculator => { :from => c_in,  :to => c_out, :duration => duration}
    end
    Calculator.find(:last)
  end
end
