
desc "This task is called by the Heroku scheduler add-on"
task :hacker_data => :environment do
	require 'nokogiri'
	require 'open-uri'

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

	hackernews_url = 'https://news.ycombinator.com/item?id=6653437'

	job_list = []

	gather_jobs(hackernews_url)


end