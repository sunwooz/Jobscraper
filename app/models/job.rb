require 'nokogiri'
require 'open-uri'

class Job < ActiveRecord::Base
	#   t.text     "content"
	#   t.timestamp "created_at"
	#   t.timestamp "updated_at"

	validates :content, uniqueness: true

	# searchable do
	# 	text :content
	# 	time :created_at
	# end

	def self.search(terms = "")
		sanitized = sanitize_sql_array(["to_tsquery('english', ?)", terms.gsub(/\s/,"+")])
		Job.where("search_vector @@ #{sanitized}")
	end
end