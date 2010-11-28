require 'test_helper'
require "authlogic/test_case"

class AccountTest < ActiveSupport::TestCase
  
 	self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures/functional")
	fixtures :levels
	fixtures :users
	fixtures :accounts
	fixtures :data
	fixtures :conversions
	fixtures :currencies
  # Replace this with your real tests.
  
  test "name_test" do
    user = create_user_for_unit
    account = user.account
    assert_difference('User.count', -1) do
      account.destroy
    end
    account.group = Group.create(:name => "Test Group")    
    assert_equal "Test Group", account.name
  end
  
  test "get_fields_test" do
    account = Account.find(:first)
    fields = account.get_fields
    assert_equal 7, fields.size
    
  end
end
