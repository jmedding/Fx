require 'test_helper'
require "authlogic/test_case"


class UsersControllerTest < ActionController::TestCase
	setup :activate_authlogic
	
	self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures/functional")
	fixtures :levels
	fixtures :users
	
	test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
		Group.create(:name => 'Base')
		assert_difference('User.count') do
      post :create, 	:user => {:name => 'Tester', 
														:login =>  'tester',
														:email => 'tester@testing.com',
														:password => 'tested',
														:password_confirmation => 'tested'},
									:group => {:name => 'test group'}			
		end
		assert Group.find_by_name('test group'), "Test Group not created"						

    assert_redirected_to user_path(assigns(:user))
  end

	test "should show user" do
		
		user = User.create(:name => 'Tester', 
														:login =>  'tester',
														:email => 'tester@testing.com',
														:password => 'tested',
														:password_confirmation => 'tested')
				UserSession.create(:login => user.login, :password => user.password, :remember_me => true)
		
		get :show, :id => user.to_param
		assert_response :success
	end

  test "should get edit" do
    get :edit, :id => users(:jon).to_param
    assert_response :success
  end

  test "should update user" do
    put :update, :id => users(:jon).to_param, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:jon).to_param
    end

    assert_redirected_to users_path
  end
end
