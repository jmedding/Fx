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
	  data1 = create_test_group #[user, group1, priv1]
	  user1 = data1[0]
	  data2 = create_test_group(user1) #[user, group1, priv1]
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
    assert_select "table.table", 1    #all of the groups are nested
    assert_template :index
  end

  test "should get new" do
    data1 = create_test_group #[user, group1, priv1]
    get :new
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test "should create group" do
    data1 = create_test_group #[user1, group1, priv1]
    assert_redirected_to group_path(assigns(:group))
    
    #test invalid case(no admin priviledges on group)
    data2 = create_test_group(nil, nil, true)
    assert_template :new
  end

  test "should show group" do
    data_1 = create_test_group #[user, group1, priv1]
    get :show, :id => data_1[1].id
    assert_response :success
    user1 = data_1[0] 
    data_2 = create_test_group #[user, group1, priv1]    
    group2 = data_2[1]   
    #Weird stuff. Current user will still be user1
    get :show, :id => group2.id
    assert_response :redirect
  end

  test "should get edit" do
    data_1 = create_test_group #[user, group1, priv1]
    group1 = data_1[1]
    get :edit, :id => group1
    assert_response :success
  end

  test "should update group" do
    data_1 = create_test_group #[user, group1, priv1]
    group1 = data_1[1]
    put :update, :id => group1.id, :group => {:name => "new_name" }
    assert_redirected_to group_path(assigns(:group))
  end

  test "should destroy group" do
    data_1 = create_test_group #[user, group1, priv1]
    group1 = data_1[1]
    assert_difference('Group.count', -1) do
      delete :destroy, :id => group1.id
    end

    assert_redirected_to groups_path
  end
  

end
