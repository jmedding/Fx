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
    #need to delete /seed/test.* otherwise it's wonky'
    #Conversion.generate_conversions!
    assert_equal 2, Conversion.count
    con = Conversion.find(:first)
    
    assert_equal 500, con.data.count
  end
  
  test "Test Conversion.update!" do
    cur = Currency.create(:symbol => "NIL")
    pln = Currency.find(3)
    p "testing dummy conversion"
    con = Conversion.create(:currency_in => cur.id, :currency_out => pln.id)  #this should normally not be scraped
    Conversion.update!  #will fail if it tries to scrap con
  end
  
  test "pair?" do
    con = conversions(:eurusd)
    assert_equal "EURUSD", con.pair?
  end

  test "get_conversion" do
    c1 = Currency.find(:first)
    c2 = Currency.find(2)
    con = Conversion.get_conversion(c1.id, c2.id)[0]
    assert_equal 500, con.data.count
  end
  
end
