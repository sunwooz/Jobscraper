class Job < ActiveRecord::Base
	validates :content, uniqueness: true

	searchable do
		text :content
	end
end