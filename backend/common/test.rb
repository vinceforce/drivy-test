require "test/unit"
require_relative "./level_functions"

class TestRentalOutput < Test::Unit::TestCase
	def crp_class
	end

	def options_day_prices
	end

	def level
	end

	def setup
		f_input = "data/input.json"
		f_expected_output = "data/expected_output.json"
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
			@rentals = {"rentals" => rentals_output}
		rescue Exception => e
			puts "Exception while processing data : " + e.message
			puts e.backtrace.inspect
		end

		begin
			expected_output_file = File.read(f_expected_output)
		rescue Exception => e
			puts "Exception while reading expected output file : " + e.message
			puts e.backtrace.inspect
		end

		begin
			@expected_output = JSON.parse(expected_output_file)
		rescue Exception => e
			puts "Exception while parsing expected output data : " + e.message
			puts e.backtrace.inspect
		end

		puts ("=" * 100).bold.magenta
		puts " Level #{level}".bold.magenta
		puts ("=" * 100).bold.magenta
		puts "+++++++++++++++++++++++++++++++++++++++++++++++++".blue
		puts "++++++++++++ Level #{level} : tests  ++++++++++++".bold
		puts "+++++++++++++++++++++++++++++++++++++++++++++++++".blue
	end

	def teardown
	## Nothing really
	end
end
