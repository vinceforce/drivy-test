require '../common/level_functions'

level = 3
crp_class = CarRentalPriceLevel3

rental_output("data/input.json", "data/output.json", "data/expected_output.json",
				level, nil, crp_class)
