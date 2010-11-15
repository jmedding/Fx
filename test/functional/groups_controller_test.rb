require 'test_helper'
require "authlogic/test_case"

class GroupsControllerTest < ActionController::TestCase
 	self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures/functional")
	fixtures :levels
	fixtures :users
	fixtures :accounts
	fixtures :data
	fixtures :conversions
	fixtures :currencies
	
	test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group" do
    data1 = create_test_group #[user1, group1, priv1]
    assert_redirected_to group_path(assigns(:group))
    
    #test invalid case(no admin priviledges on group)
    data2 = create_test_group(nil, nil, true)
    assert_template :new
  end

  test "should show group" do
    get :show, :id => groups(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => groups(:one).to_param
    assert_response :success
  end

  test "should update group" do
    put :update, :id => groups(:one).to_param, :group => { }
    assert_redirected_to group_path(assigns(:group))
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete :destroy, :id => groups(:one).to_param
    end

    assert_redirected_to groups_path
  end
  

end
