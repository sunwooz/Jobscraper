class HackerNewsJobPost < ActiveRecord::Base
	# t.string "post_link"
	# t.string "post_title"
	# t.string "post_date"

	validates :post_title, uniqueness: true
	validates :post_link, uniqueness: true
end
