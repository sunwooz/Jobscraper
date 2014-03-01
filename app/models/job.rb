class Job < ActiveRecord::Base
	validates :content, uniqueness: true

	def self.search(terms="", location)
		result = Job.search_result_for_blank_query(terms, location).order("created_at DESC") if terms.blank?
		result = Job.search_result_for_query(terms, location).order("created_at DESC") if !terms.blank?
		result
	end

	private

		def self.city_hash
			cities = {
				'New York City' => ['NYC', 'new york city', 'new york', 'ny'],
				'San Francisco' => ['SF', 'San', 'SFrancisco']
			}
		end

		def self.to_location_query(location)
			cities = Job.city_hash
			location_query = cities[location].map do |city|
					city.gsub(/\s/, "+")
			end.join("|")
			location_query = "(" + location_query + ")"
			sanitized_locations = sanitize_sql_array(["to_tsquery('english', ?)", location_query])
		end

		def self.search_result_for_query(terms, location)
			if location == "All Cities"
				sanitized = sanitize_sql_array(["to_tsquery('english', ?)", terms.gsub(/\s/, "+")])
				result = Job.where("search_vector @@ #{sanitized}")
			elsif location != "All Cities"
				cities = Job.city_hash
				location_query = Job.convert_location_hash_to_sql(location)
				location_query = "(" + location_query + ")"
				result = Job.where("search_vector @@ to_tsquery('english', '#{location_query} & #{terms.gsub(/\s/, '+')}')")
			end
			result
		end

		def self.search_result_for_blank_query(terms, location)
			if location == "All Cities"
				result = Job.all
			elsif !location.blank?
				sanitized_location_query = Job.to_location_query(location)
				result = Job.where("search_vector @@ #{sanitized_location_query}")
			else
				result = Job.all(limit:15)
			end
			result
		end

		def self.convert_location_hash_to_sql(location)
			cities[location].map do |city|
						city.gsub(/\s/, "+")
			end.join("|")
		end

end