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
    assert_difference('Exposure.count') do
      post :create, :exposure => { }
    end

    assert_redirected_to exposure_path(assigns(:exposure))
  end

  test "should show exposure" do
    get :show, :id => exposures(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => exposures(:one).to_param
    assert_response :success
  end

  test "should update exposure" do
    put :update, :id => exposures(:one).to_param, :exposure => { }
    assert_redirected_to exposure_path(assigns(:exposure))
  end

  test "should destroy exposure" do
    assert_difference('Exposure.count', -1) do
      delete :destroy, :id => exposures(:one).to_param
    end

    assert_redirected_to exposures_path
  end
  
  def create_test_exposure( c1, c2, validity, amount, carried = nil, user = nil)
    user = create_test_user unless user
    c = Conversion.find_by_currency_in_and_currency_out(Currency.find_by_symbol(c1).id, Currency.find_by_symbol(c2).id)
    post :create,
     :tender => {:group => user.groups.find(:first), 
                  :user => user,
                  :description => 'Test Tender',
                  "bid_date(1i)" => (Date.today + 10).strftime("%Y"),
                  "bid_date(2i)" => (Date.today + 10).strftime("%m"),
                  "bid_date(3i)" => (Date.today + 10).strftime("%d"),
                  :validity => validity},
     :exposure => {:supply => true,
                  :currency_in => Currency.find_by_symbol(c1).id,
                  :currency_out => Currency.find_by_symbol(c2).id,
                  :carried_rate => carried,
                  :amount => amount}
  
    return Exposure.find_by_amount(amount)  #must be careful to use unique amounts in our tests        
  end
  
  def create_test_user(suffix = "", invalid = false)
    assert_difference('User.count') do
      old_controller = @controller
      @controller = UsersController.new
      blahblahblah = invalid ? "sfkndsfk" : ""
      suffix = suffix.to_s
      Group.create!(:name => 'Base') unless Group.find_by_name("Base")
      post :create, :user => {:name => 'Tester' + suffix, 
														:login =>  'tester' + suffix,
														:email => 'tester' + suffix+ '@testing.com',
														:password => 'tested' + suffix + blahblahblah,
														:password_confirmation => 'tested' + suffix},
			  						:group => {:name => 'test group'}			
      @controller = old_controller 
    end 
         
		user = User.find_by_name('Tester' + suffix)
  end
end
