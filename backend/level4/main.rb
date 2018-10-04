require '../common/level_functions'

level = 4
crp_class = CarRentalPriceLevel4

rental_output("data/input.json", "data/output.json", "data/expected_output.json",
				level, nil, crp_class)
