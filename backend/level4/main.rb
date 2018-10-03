require '../common/level_functions'

def car_rental_price(cars, rental, options, options_day_prices)
	rental_id = rental["id"]
	car_id = rental["car_id"]
	duration = (Date.parse(rental["end_date"]) - Date.parse(rental["start_date"])).to_i + 1
	distance = rental["distance"].to_i

	car = cars.find {|c| c["id"] == car_id}
	price_per_day = car["price_per_day"].to_i
	price_per_km = car["price_per_km"].to_i

	price_days = price_days_compute(duration, price_per_day)
	price_distance = distance * price_per_km
	price = price_days + price_distance

	commission = commission_compute(price, duration)

	actions = actions_compute(price, commission, nil, nil)

	return { "id" => rental_id, "actions" => actions}
end

level = 4
rental_output("data/input.json", "data/output.json", "data/expected_output.json", level, nil)
