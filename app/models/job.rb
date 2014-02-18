require 'nokogiri'
require 'open-uri'

class Job < ActiveRecord::Base
	validates :content, uniqueness: true

	def self.search(terms = "")
		if terms.blank?
			result = Job.all(limit: 15)
		else
			sanitized = sanitize_sql_array(["to_tsquery('english', ?)", terms.gsub(/\s/,"+")])
			result = Job.where("search_vector @@ #{sanitized}")
		end
		return result
	end
end