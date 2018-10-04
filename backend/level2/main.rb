require '../common/level_functions'

level = 2
crp_class = CarRentalPriceLevel2

rental_output("data/input.json", "data/output.json", "data/expected_output.json",
				level, nil, crp_class)
