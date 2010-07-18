require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
	self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures/unit")
	fixtures :currencies
	
	# Replace this with your real tests.
	test "the truth" do
		assert true
	end
	
	test "get method" do
		Currency.create(:symbol => 'EUR')
		Currency.create(:symbol => 'USD')
		puts "Currency count = #{Currency.count}"
		assert Currency.get.symbol == 'EUR', "get dedault currency, EUR, failed"
		assert Currency.get('USD').symbol == 'USD', "get currency USD failed"
	end
	
end
