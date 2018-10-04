require "../common/test.rb"

class TestRentalOutputLevel4 < TestRentalOutput
	def crp_class
		CarRentalPriceLevel4
	end

	def options_day_prices
		nil
	end

	def level
		4
	end

	def test_simple
		assert_equal( @expected_output, @rentals )
	end
end