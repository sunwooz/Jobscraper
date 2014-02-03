require 'nokogiri'
require 'open-uri'

desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
	gather_urls(hackernews_url)
end

hackernews_url = 'https://news.ycombinator.com/item?id=7162197'

def gather_urls(initial_link)
	doc = Nokogiri::HTML( open( initial_link ) )
	puts doc
end
