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
    assert_difference ('Calculator.count') do
      calc = Calculator.create( :to => "EUR",
                                :from => "USD",
                                :duration => 30
                              )
    end
                            
  end
end
