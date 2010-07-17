require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
 end
 
 test "get_unique_group_branches" do
	 u = users(:jon)
	 puts u.name
	 Group.rebuild! if u.groups[0].lft.blank?
	 assert u.groups.size > 1
	 assert u.get_unique_group_branches.size == 1
 end
 
end
