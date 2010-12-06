require 'test_helper'

class ConversionTest < ActiveSupport::TestCase
 	self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures/functional")
	fixtures :levels
	fixtures :users
	fixtures :accounts
	fixtures :data
	fixtures :conversions
	fixtures :currencies
	

  
  test "Generate_Conversions" do
    Conversion.generate_conversions!
    assert_equal 2, Conversion.count
    con = Conversion.find(:first)
    
    assert_equal 500, con.data.count
  end
  
  test "pair?" do
    con = conversions(:eurusd)
    assert_equal "EURUSD", con.pair?
  end

  test "get_conversion" do
    c1 = Currency.find(:first)
    c2 = Currency.find(:last)
    con = Conversion.get_conversion(c1.id, c2.id)[0]
    assert_equal 500, con.data.count
  end
  
end
