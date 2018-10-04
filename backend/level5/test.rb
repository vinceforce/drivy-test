require "../common/test.rb"

class TestRentalOutputLevel5 < TestRentalOutput
	def crp_class
		CarRentalPriceLevel5
	end

	def options_day_prices
		{
			"gps" => 500,
			"baby_seat" => 200,
			"additional_insurance" => 1000
		}
	end

	def level
		5
	end

	def test_simple
		assert_equal( @expected_output, @rentals )
	end
end