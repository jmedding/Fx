require 'test_helper'
require "authlogic/test_case"

class ExposuresControllerTest < ActionController::TestCase
  
 	self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures/functional")
	fixtures :levels
	fixtures :users
	fixtures :accounts
	fixtures :data
	fixtures :conversions
	fixtures :currencies
	
	
  test "should get index" do
    e1 = create_test_exposure('EUR', 'USD', 20, 25000)
    get :index
    assert_response :success
    assert_not_nil assigns(:exposures)
    assert_template :index, "The index template failed to be returned"
  end

  test "should get new" do
    user = create_test_user
    get :new
    assert_response :success
    assert_template :new, "The new template was not returned"

    con_old = @controller
    @controller = AccountsController.new
    post :update, :id => user.account.id, :type_id => 1 
    @controller = con_old
    user = User.find(user.id)
    get :new
    assert_redirected_to tenders_path
    e1 = create_test_exposure('EUR', 'USD', 20, 26000, nil, user)
    #p user.exposures.inspect
    get :new, :tender => {:id => user.tenders.find(:first).id}
    assert_response :success
    assert_template :new
  end

  test "should create exposure" do
    user = create_test_user
    assert_difference('Exposure.count') do
      exp1 = create_test_exposure('EUR', 'USD', 20, 27000, nil, user)
    end
    exp2 = create_test_exposure('EUR', 'USD', 20, 28000, nil, user)
    exp3 = create_test_exposure('USD', 'EUR', 20, 29000, nil, user)
    
    assert (exp3.carried_rate - exp3.recommended_rate?)**2 < 0.001
    r2 = exp2.current_rate
    r3 = exp3.current_rate
    
    assert_redirected_to exposure_path(assigns(:exposure))
    assert (r2 - 1/r3)**2 < 0.1, "something is wrong with the inversion"
    exp4 = create_test_exposure('USD', 'EUR', 20, 30000, 0.19, user)
    assert_equal 0.19, exp4.carried_rate, "carried rate has a problem"
    
  end

  test "should show exposure" do
    exp1 = create_test_exposure('EUR', 'USD', 20, 31000)
    get :show, :id => exp1.id
    assert_response :success
  end

  test "should get edit" do
    exp1 = create_test_exposure('EUR', 'USD', 20, 32000)
    get :edit, :id => exp1.id
    assert_response :success
    assert_template :edit
  end

  test "should update exposure" do
    exp1 = create_test_exposure('EUR', 'USD', 20, 33000)
    r1 = exp1.carried_rate
    r2 = r1 * 1.1
    put :update, :id => exp1.id, :exposure => { :carried_rate => r2 }
    assert_redirected_to exposure_path(assigns(:exposure))
    exp1_updated = Exposure.find_by_id(exp1.id)
    assert_equal (r2*10**3).round, (exp1_updated.carried_rate*10**3).round
  end

  test "should destroy exposure" do
    exp1 = create_test_exposure('EUR', 'USD', 20, 34000)
    assert_difference('Exposure.count', -1) do
      delete :destroy, :id => exp1.id
    end

    assert_redirected_to exposures_path
  end
  

end
