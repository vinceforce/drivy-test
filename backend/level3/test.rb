require "../common/test.rb"

class TestRentalOutputLevel3 < TestRentalOutput
	def crp_class
		CarRentalPriceLevel3
	end

	def options_day_prices
		nil
	end

	def level
		3
	end

	def test_simple
		assert_equal( @expected_output, @rentals )
	end
end