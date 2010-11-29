require 'test_helper'

class CalculatorTest < ActiveSupport::TestCase
  
 	self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures/functional")
	fixtures :levels
	fixtures :users
	fixtures :accounts
	fixtures :data
	fixtures :conversions
	fixtures :currencies
	
  test "calculator validations" do
    
    #currencies are different
    assert_difference('Calculator.count') do
      calc = get_calc
    end
    assert_difference('Calculator.count', 0) do
      calc = get_calc "EUR", "EUR", 30
    end 
    assert_difference('Calculator.count', 0) do
      calc = get_calc "USD", "FU", 166
    end    
    
    #assert duration will be limitted
    calc = nil
    
    #we have a model validation that  duration is < 2710. As this is done on save, 
    #if normally never gets used as the 'symbols_are_valid' will check and reduce
    #the duration as needed, before saving.
        
    bad_calc = get_calc "USD", "EUR", 2711
    assert_not_equal 2711, bad_calc.duration
    calc = get_calc "USD", "EUR", 2000
    assert_not_equal 2000, calc.duration
    calc2 = get_calc "USD", "EUR", 166
    assert_equal 166, calc2.duration
  end
  
  test "get_current_rate" do 
    assert_equal 0.198, my_round(get_calc.get_current_rate, 3)
  end
  
  test "get_recommended_rate" do
    assert_equal( 0.195, my_round(get_calc.get_recommended_rate, 3))
  end
  
  test "get_provision" do
    assert_equal( 1.418, my_round(get_calc.get_provision, 3))
  end
  
  test "get_max_duration" do
    calc = get_calc
    assert_equal(166, calc.get_max_duration)
  end  

  def get_calc(from = "USD", to = "EUR", duration = 30)
    calc = Calculator.create( :to => to, :from => from, :duration => duration )
  end
end
