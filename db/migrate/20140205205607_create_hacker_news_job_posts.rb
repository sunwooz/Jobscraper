class CreateHackerNewsJobPosts < ActiveRecord::Migration
	def change
		create_table :hacker_news_job_posts do |t|
			t.string :post_link
			t.string :post_title
			t.date :post_date
		end
	end
end
