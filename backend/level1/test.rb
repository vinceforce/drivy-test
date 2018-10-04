require "../common/test.rb"

class TestRentalOutputLevel1 < TestRentalOutput
	def crp_class
		CarRentalPriceLevel1
	end

	def options_day_prices
		nil
	end

	def level
		1
	end

	def test_simple
		assert_equal( @expected_output, @rentals )
	end
end