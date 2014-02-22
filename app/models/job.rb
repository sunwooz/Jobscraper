require 'nokogiri'
require 'open-uri'

class Job < ActiveRecord::Base
	validates :content, uniqueness: true

	def self.search(terms = "", location)
		# if terms.blank?
		# 	result = Job.all(limit: 15)
		# else
		# 	sanitized = sanitize_sql_array(["to_tsquery('english', ?)", terms.gsub(/\s/,"+")])
		# 	result = Job.where("search_vector @@ #{sanitized}")
		# end
		# result

		if terms.blank?
			if location == "All Cities"
				sanitized = sanitize_sql_array(["to_tsquery('english', ?)", terms.gsub(/\s/,"+")])
				result = Job.all
			elsif !location.blank?
				sanitized_location_query = Job.to_location_query(location)
				result = Job.where("search_vector @@ #{sanitized_location_query}")
			else
				result = Job.all(limit:15)
			end

		elsif !terms.blank?
			if location == "All Cities"
				sanitized = sanitize_sql_array(["to_tsquery('english', ?)", terms.gsub(/\s/, "+")])
				result = Job.where("search_vector @@ #{sanitized}")
			else #elsif location is something different
				#filter for the location + all query results
			end
		end
		result
	end

	private
		def self.to_location_query(location)
			cities = {
				'New York City' => ['NYC', 'new york city', 'new york', 'ny'],
				'San Francisco' => ['SF', 'San', 'SFrancisco']
			}
			location_query = cities[location].map do |city|
					city.gsub(/\s/, "+")
			end.join("|")
			location_query = "(" + location_query + ")"
			sanitized_locations = sanitize_sql_array(["to_tsquery('english', ?)", location_query])
		end
end