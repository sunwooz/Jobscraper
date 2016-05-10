class Job < ActiveRecord::Base
	validates :content, uniqueness: true
	has_many :comments
	default_scope { order('created_at DESC') }

	def self.search(terms="", location)
		result = Job.search_result_for_blank_query(terms, location) if terms.blank?
		result = Job.search_result_for_query(terms, location) if !terms.blank?
		result
	end

	private

		def self.to_location_query(location)
			alternative_city_names = City.find_by(name: location).alternative_names
			location_query = alternative_city_names.map do |city|
				city.gsub(/\s/, "+")
			end.join("|")
			location_query = "(" + location_query + ")"
			sanitized_locations = sanitize_sql_array(["to_tsquery('english', ?)", location_query])
		end

		def self.search_result_for_query(terms, location)
			if location == "All Cities"
				sanitized = sanitize_sql_array(["to_tsquery('english', ?)", terms.gsub(/\s/, "+")])
				result = Job.where("search_vector @@ #{sanitized}").order("created_at DESC")
			elsif location != "All Cities"
				location_query = Job.convert_location_hash_to_sql(location)
				location_query = "(" + location_query + ")"
				result = Job.where("search_vector @@ to_tsquery('english', '#{location_query} & #{terms.gsub(/\s/, '+')}')").order("created_at DESC")
			end
			result
		end

		def self.search_result_for_blank_query(terms, location)
			if location == "All Cities"
				result = Job.all.order("created_at DESC")
			elsif !location.blank?
				sanitized_location_query = Job.to_location_query(location)
				result = Job.where("search_vector @@ #{sanitized_location_query}").order("created_at DESC")
			else
				result = []
			end
			result
		end

		def self.convert_location_hash_to_sql(location)
			alternative_city_names = City.find_by(name: location).alternative_names
			alternative_city_names.map do |city|
						city.gsub(/\s/, "+")
			end.join("|")
		end

end
