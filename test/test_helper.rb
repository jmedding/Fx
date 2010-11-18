ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def create_test_group(user = nil, parent = nil, invalid = false)
    i = rand(1000)
    user = create_test_user(i) if user.blank?
    parent = user.groups.find(:last)
    unless invalid
      priv = user.priviledges.find_by_group_id(parent.id)
      priv.level = Level.find_by_name('admin') unless invalid #will not have proper group priviledge required to create a new group
      priv.save!
    end
    name = "Test Group #{i}"
    delta = invalid ? 0 : 1
    assert_difference('Group.count', delta) do
      post :create, :group => {:parent_id => parent.id, :name => name }      
    end
    group = user.groups.find_by_name(name)      
    priv_new = nil
    unless invalid
      priv_new = user.priviledges.find_by_group_id(group.id)  
      assert_not_nil priv_new
      assert_equal Level.find_by_name('admin').id, priv_new.level_id    
    end
    return [user, group, priv_new]  
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
    delta = invalid ? 0 : 1
    assert_difference('User.count', delta) do
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
