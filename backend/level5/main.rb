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

	rental_options = options.select { |o| o["rental_id"] == rental["id"] }
	owner_options = rental_options.select { |o| o["type"] == "gps" or o["type"] == "baby_seat" }
	owner_options_amount = owner_options.inject(0) {
			|sum, o| sum + duration * options_day_prices[o["type"]]
		}
	drivy_options = rental_options.select { |o| o["type"] == "additional_insurance" }
	drivy_options_amount = drivy_options.inject(0) {
			|sum, o| sum + duration * options_day_prices[o["type"]]
		}
	options_output = rental_options.map {|o| o["type"]}

	actions = actions_compute(price, commission, owner_options_amount, drivy_options_amount)

	return { "id" => rental_id, "options" => options_output, "actions" => actions}
end

options_day_prices = {
	"gps" => 500,
	"baby_seat" => 200,
	"additional_insurance" => 1000
}

level = 5
rental_output("data/input.json", "data/output.json", "data/expected_output.json", level,
				options_day_prices)
