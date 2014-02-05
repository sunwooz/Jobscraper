require 'nokogiri'
require 'open-uri'
require 'date'

class Job < ActiveRecord::Base
	validates :content, uniqueness: true

	searchable do
		text :content
	end

	private

		def get_latest_job_post
			whoishiring_page = 'https://news.ycombinator.com/submitted?id=whoishiring'
			doc = Nokogiri::HTML( open( whoishiring_page ) )
		end

		def gather_jobs(initial_link)
			doc = Nokogiri::HTML( open( initial_link ) )
			doc.css('span.comment').each do |comment|
				string_comment = comment.text()
				Job.create(content: string_comment)
			end

			more_link = doc.css('a:contains("More")')
			unless more_link.empty?
				base_url = 'https://news.ycombinator.com'
				the_href = more_link.attribute('href')
				hacker_url = base_url + the_href
				gather_jobs( hacker_url )
			end
		end

		def check_time( scheduled_link )
			date = Date.today
			if date == Date.new(2014, 2, 3)
				puts 'Gathering jobs'
				gather_jobs(scheduled_link)
			else
				puts 'It is not time to gather jobs yet'
			end
		end

		scheduled_link = 'https://news.ycombinator.com/item?id=6653437'

		job_list = []

		check_time( scheduled_link )

end