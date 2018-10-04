require 'json/ext'
require 'date'

class String
	def black;          "\e[30m#{self}\e[0m" end
	def red;            "\e[31m#{self}\e[0m" end
	def green;          "\e[32m#{self}\e[0m" end
	def brown;          "\e[33m#{self}\e[0m" end
	def blue;           "\e[34m#{self}\e[0m" end
	def magenta;        "\e[35m#{self}\e[0m" end
	def cyan;           "\e[36m#{self}\e[0m" end
	def gray;           "\e[37m#{self}\e[0m" end

	def bg_black;       "\e[40m#{self}\e[0m" end
	def bg_red;         "\e[41m#{self}\e[0m" end
	def bg_green;       "\e[42m#{self}\e[0m" end
	def bg_brown;       "\e[43m#{self}\e[0m" end
	def bg_blue;        "\e[44m#{self}\e[0m" end
	def bg_magenta;     "\e[45m#{self}\e[0m" end
	def bg_cyan;        "\e[46m#{self}\e[0m" end
	def bg_gray;        "\e[47m#{self}\e[0m" end

	def bold;           "\e[1m#{self}\e[22m" end
	def italic;         "\e[3m#{self}\e[23m" end
	def underline;      "\e[4m#{self}\e[24m" end
	def blink;          "\e[5m#{self}\e[25m" end
	def reverse_color;  "\e[7m#{self}\e[27m" end
end

def puts_error(msg, e)
	puts (msg + e.message).bold.red
	puts e.backtrace.inspect
end

def days_number(duration, number)
	days = (duration >= number)?duration-number:0
rescue Exception => e
	puts_error('CarRentalPrice - Error while computing days_number : ', e)
end

def price_days_compute(duration, price_per_day)
	days_10 = days_number(duration, 10)
	days_4 = days_number(duration - days_10, 4)
	days_1 = days_number(duration - days_10 - days_4, 1)
	days_0 = duration - days_10 - days_4 - days_1
	price_days = price_per_day * (days_0 + days_1 * 0.9 + days_4 * 0.7 + days_10 * 0.5)
	return price_days.round(0)
rescue Exception => e
	puts_error('CarRentalPrice - Error while computing price_days : ', e)
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
rescue Exception => e
	puts_error('CarRentalPrice - Error while computing commission : ', e)
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
rescue Exception => e
	puts_error('CarRentalPrice - Error while computing actions : ', e)
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
rescue Exception => e
	puts_error('CarRentalPrice - Error while computing options : ', e)
end

class CarRentalPrice
	def initialize(cars, r, options, options_day_prices)
		@cars = cars
		@rental = r
		@options = options
		@options_day_prices = options_day_prices
		@rental_id = @rental["id"]
		begin
			@duration = (Date.parse(@rental["end_date"]) - Date.parse(@rental["start_date"])).to_i + 1
		rescue Exception => e
			puts_error('CarRentalPrice - Error while parsing date : ', e)
		end
		begin
			@distance = @rental["distance"].to_i
		rescue Exception => e
			puts_error('CarRentalPrice - Error while parsing distance : ', e)
		end
		@car_id = @rental["car_id"]
		begin
			@car = @cars.find {|c| c["id"] == @car_id}
		rescue Exception => e
			puts_error('CarRentalPrice - Error while retrieving car : ', e)
		end
		begin
			@price_per_day = @car["price_per_day"].to_i
			if @price_per_day == 0
				raise 'price_per_day is not available'
			end
		rescue Exception => e
			puts_error('CarRentalPrice - Error while retrieving car price_per_day : ', e)
		end
		begin
			@price_per_km = @car["price_per_km"].to_i
			if @price_per_km == 0
				raise 'price_per_km is not available'
			end
		rescue Exception => e
			puts_error('CarRentalPrice - Error while retrieving car price_per_km : ', e)
		end

	end

	def price_days
		@duration * @price_per_day
	rescue Exception => e
		puts_error('CarRentalPrice - Error while computing price_days : ', e)
	end

	def price_distance
		@distance * @price_per_km
	rescue Exception => e
		puts_error('CarRentalPrice - Error while computing price_distance : ', e)
	end

	def price
		price_days + price_distance
	rescue Exception => e
		puts_error('CarRentalPrice - Error while computing price : ', e)
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
		puts_error("Exception while reading input file : ", e)
	end
	begin
		input_data = JSON.parse(input_file)
	rescue Exception => e
		puts_error("Exception while parsing input file : ", e)
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
		puts_error("Exception while processing data : ", e)
	end

	begin
		File.open(f_output, "w") {|f| f.write(JSON.pretty_generate(rentals)) }
	rescue Exception => e
		puts_error("Exception while writing output data to output file : ", e)
	end

	puts ("*" * 55).blue
	puts "************* Level #{level} : output generated **************".bold
	puts ("*" * 55).blue
	puts ("=" * 100).bold.magenta
end

