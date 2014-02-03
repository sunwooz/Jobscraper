
desc "This task is called by the Heroku scheduler add-on"
task :hacker_data => :environment do
	require 'nokogiri'
	require 'open-uri'

	def gather_urls(initial_link)
		doc = Nokogiri::HTML( open( initial_link ) )
		puts doc
	end

	hackernews_url = 'https://news.ycombinator.com/item?id=7162197'

	gather_urls(hackernews_url)


end


