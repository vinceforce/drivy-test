require '../common/level_functions'

options_day_prices = {
	"gps" => 500,
	"baby_seat" => 200,
	"additional_insurance" => 1000
}

level = 5
crp_class = CarRentalPriceLevel5

rental_output("data/input.json", "data/output.json", "data/expected_output.json",
				level, options_day_prices, crp_class)
