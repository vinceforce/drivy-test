require '../common/level_functions'

level = 1
crp_class = CarRentalPriceLevel1

rental_output("data/input.json", "data/output.json", "data/expected_output.json",
				level, nil, crp_class)

