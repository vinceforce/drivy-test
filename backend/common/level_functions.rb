require 'json/ext'
require 'date'

def days_number(duration, number)
	days = (duration >= number)?duration-number:0
end

def price_days_compute(duration, price_per_day)
	days_10 = days_number(duration, 10)
	days_4 = days_number(duration - days_10, 4)
	days_1 = days_number(duration - days_10 - days_4, 1)
	days_0 = duration - days_10 - days_4 - days_1
	price_days = price_per_day * (days_0 + days_1 * 0.9 + days_4 * 0.7 + days_10 * 0.5)
	return price_days.round(0)
end

def commission_compute(price, duration)
	price_30 = 0.3 * price
	insurance_fee = (price_30 * 0.5).round(0)
	assistance_fee = 100 * duration # rental prices are given in cents, 1 € = 100 cts
	drivy_fee = (price_30 - insurance_fee - assistance_fee).round(0)
	{
		"insurance_fee" => insurance_fee,
		"assistance_fee" => assistance_fee,
		"drivy_fee" => drivy_fee
	}
end

def actions_compute(price, commission, owner_options_amount, drivy_options_amount)
	owner_amount = (owner_options_amount)?owner_options_amount:0
	drivy_amount = (drivy_options_amount)?drivy_options_amount:0
	actions = []
	actions.push({
		"who" => "driver",
		"type" => "debit",
		"amount" => price + owner_amount + drivy_amount
	})
	actions.push({
		"who" => "owner",
		"type" => "credit",
		"amount" => (price * 0.7).round(0) + owner_amount
	})
	actions.push({
		"who" => "insurance",
		"type" => "credit",
		"amount" => commission["insurance_fee"]
	})
	actions.push({
		"who" => "assistance",
		"type" => "credit",
		"amount" => commission["assistance_fee"]
	})
	actions.push({
		"who" => "drivy",
		"type" => "credit",
		"amount" => commission["drivy_fee"] + drivy_amount
	})
	return actions
end

def options_compute(rental_id)
	rental_options = @options.select { |o| o["rental_id"] == @rental_id }
	owner_options = rental_options.select { |o| o["type"] == "gps" or o["type"] == "baby_seat" }
	owner_options_amount = owner_options.inject(0) {
			|sum, o| sum + @duration * @options_day_prices[o["type"]]
		}
	drivy_options = rental_options.select { |o| o["type"] == "additional_insurance" }
	drivy_options_amount = drivy_options.inject(0) {
			|sum, o| sum + @duration * @options_day_prices[o["type"]]
		}
	options_output = rental_options.map {|o| o["type"]}
	{
		:owner_options_amount => owner_options_amount,
		:drivy_options_amount => drivy_options_amount,
		:options_output => options_output
	}
end

class CarRentalPrice
	def initialize(cars, r, options, options_day_prices)
		@cars = cars
		@rental = r
		@options = options
		@options_day_prices = options_day_prices
		@rental_id = @rental["id"]
		@duration = (Date.parse(@rental["end_date"]) - Date.parse(@rental["start_date"])).to_i + 1
		@distance = @rental["distance"].to_i
		@car_id = @rental["car_id"]
		@car = @cars.find {|c| c["id"] == @car_id}
		@price_per_day = @car["price_per_day"].to_i
		@price_per_km = @car["price_per_km"].to_i

	end

	def price_days
		@duration * @price_per_day
	end

	def price_distance
		@distance * @price_per_km
	end

	def price
		price_days + price_distance
	end

	def output
		{ "id" => @rental_id, "price" => self.price() }
	end
end

class CarRentalPriceLevel1 < CarRentalPrice
end

class CarRentalPriceLevel2 < CarRentalPrice
	def price_days
		price_days_compute(@duration, @price_per_day)
	end
end

class CarRentalPriceLevel3 < CarRentalPriceLevel2
	def commission
		commission_compute(price, @duration)
	end

	def output
		{ "id" => @rental_id, "price" => price , "commission" => commission}
	end
end

class CarRentalPriceLevel4 < CarRentalPriceLevel3
	def actions
		actions_compute(price, commission, nil, nil)
	end

	def output
		{ "id" => @rental_id, "actions" => actions}
	end
end

class CarRentalPriceLevel5 < CarRentalPriceLevel3
	def options
		options_compute(@rental_id)
	end

	def actions
		owner_options_amount = options[:owner_options_amount]
		drivy_options_amount = options[:drivy_options_amount]
		actions_compute(price, commission, owner_options_amount, drivy_options_amount)
	end


	def output
		options_output = options[:options_output]
		{ "id" => @rental_id, "options" => options_output, "actions" => actions}
	end
end

def car_rental_price(cars, r, options, options_day_prices, crp_class)
	crp = crp_class.new(cars, r, options, options_day_prices)
	crp.output
end

def rental_output(f_input, f_output, f_expected_output, level, options_day_prices, crp_class)
	begin
		input_file = File.read(f_input)
	rescue Exception => e
		puts "Exception while reading input file : " + e.message
		puts e.backtrace.inspect
	end
	begin
		input_data = JSON.parse(input_file)
	rescue Exception => e
		puts "Exception while parsing input file : " + e.message
		puts e.backtrace.inspect
	end

	cars = input_data["cars"]
	rentals_input = input_data["rentals"]
	options = input_data["options"]

	begin
		rentals_output = rentals_input.map {
				|r| car_rental_price(cars, r, options, options_day_prices, crp_class)
			}
		rentals = {"rentals" => rentals_output}
	rescue Exception => e
		puts "Exception while processing data : " + e.message
		puts e.backtrace.inspect
	end

	begin
		File.open(f_output, "w") {|f| f.write(JSON.pretty_generate(rentals)) }
	rescue Exception => e
		puts "Exception while writing output data to output file : " + e.message
		puts e.backtrace.inspect
	end

	begin
		expected_output_file = File.read(f_expected_output)
	rescue Exception => e
		puts "Exception while reading expected output file : " + e.message
		puts e.backtrace.inspect
	end
	
	begin
		expected_output = JSON.parse(expected_output_file)
	rescue Exception => e
		puts "Exception while parsing expected output data : " + e.message
		puts e.backtrace.inspect
	end

	puts "Level %{level} : test %{test}" %
		{:level => level, :test => (rentals == expected_output) ? "ok" : "ko"}
end

