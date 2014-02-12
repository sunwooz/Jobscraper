require 'nokogiri'
require 'open-uri'

class Job < ActiveRecord::Base
	#   t.text     "content"
	#   t.timestamp "created_at"
	#   t.timestamp "updated_at"

	validates :content, uniqueness: true

	searchable do
		text :content
		time :created_at
	end

	private

		def get_latest_job_post_link
			ordered_posts = HackerNewsJobPost.all.order(post_date: :desc) # =>
			latest_post_link = ordered_posts.first.post_link
		end

		def self.gather_jobs
			initial_link = get_latest_job_post_link
			doc = Nokogiri::HTML( open( initial_link ) )
			doc.css('span.comment').each do |comment|
				string_comment = comment.text()
				Job.create(content: string_comment)
			end

			########### TODO: explicitly grab the LAST More link #############
			more_link = doc.css('a:contains("More")')
			unless more_link.empty?
				base_url = 'https://news.ycombinator.com'
				the_href = more_link.attribute('href')
				hacker_url = base_url + the_href
				gather_jobs( gather_jobs(initial_link) )
			end
		end
end