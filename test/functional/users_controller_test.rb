require 'test_helper'
require "authlogic/test_case"


class UsersControllerTest < ActionController::TestCase
	setup :activate_authlogic
	
	self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures/functional")
	fixtures :levels
	fixtures :users
	fixtures :accounts
	
	test "should get index" do
	  user = create_test_user
    get :index
    assert_response :redirect
    assert_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
		
		assert_difference('User.count') do
		  user = create_test_user
    end
    group = Group.find_by_name('test group')
		user = User.find_by_name('Tester')
		assert group, "Test Group not created"						
		assert_equal user.account.group.name, 'test group', "Account test failed in user creation"
		assert_equal group.account.creator_id, user.id, "Account test failed in user creation"
		assert_redirected_to user_path(assigns(:user)) #should we really redirect back to show(user) after creating?
  end

	test "should show user" do
		user = create_test_user
		get :show, :id => user.to_param
		assert_redirected_to groups_path    #admin filter at work
	end

  test "should get edit" do
    user = create_test_user
    
    get :edit, :id => user.id
    assert_response :success
    looser = create_test_user("1")  #user will remain current_user (don't know why...)
    get :edit, :id => looser.id
    assert_redirected_to user_path(user) #should redirect to current_user user-show page, but this redirects
    
  end

  test "should update user" do
    user = create_test_user
    put :update, :id => user.id, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    user = create_test_user
    assert_difference('User.count', -1) do
      delete :destroy, :id => user.id
    end
    assert_redirected_to users_path
  end
  
  def create_test_user(suffix = "")
    Group.create!(:name => 'Base') unless Group.find_by_name("Base")
    post :create, 	:user => {:name => 'Tester' + suffix, 
														:login =>  'tester' + suffix,
														:email => 'tester' + suffix+ '@testing.com',
														:password => 'tested' + suffix,
														:password_confirmation => 'tested' + suffix},
									:group => {:name => 'test group'}			
		user = User.find_by_name('Tester' + suffix)
  end
end
