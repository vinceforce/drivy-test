require "../common/test.rb"

class TestRentalOutputLevel2 < TestRentalOutput
	def crp_class
		CarRentalPriceLevel2
	end

	def options_day_prices
		nil
	end

	def level
		2
	end

	def test_simple
		assert_equal( @expected_output, @rentals )
	end
end