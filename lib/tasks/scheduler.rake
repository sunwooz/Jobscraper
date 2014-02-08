require 'nokogiri'
require 'open-uri'
require 'date'

namespace :hn do
	desc "get a list of HN Hiring Now links and put in database"
	task :link_populate => :environment do
		whoishiring_page = 'https://news.ycombinator.com/submitted?id=whoishiring'
		hacker_base_url = 'https://news.ycombinator.com/'
		doc = Nokogiri::HTML( open( whoishiring_page ) )
		doc.css('a').each do |link|
			link_text = link.text
			if link.text.include?('Ask HN: Who is hiring?')
				job_post_link = hacker_base_url + link.attribute('href')
				date_published = Date.parse( link.text )
				HackerNewsJobPost.create(post_link: job_post_link, post_title: link.text, post_date: date_published)
				puts "#{link_text} added."
			end
		end
	end

	desc "grab and update all job 'comments' from all job 'posts'"
	task :db_populate_all => :environment do
		job_post_list = HackerNewsJobPost.all
		job_post_list.each do |job_post|
			post_link = job_post.post_link
			post_date = job_post.post_date
			post_date_in_words = post_date.strftime("%B %d, %Y")
			post_title = job_post.post_title
			puts "Populating jobs for: #{post_title}, posted on: #{post_date_in_words}."
			gather_jobs(post_link, post_date)
			sleep(3)
		end
	end
end

def gather_jobs(initial_link, post_date)
	doc = Nokogiri::HTML( open( initial_link, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.102 Safari/537.36' ) )
	doc.css('span.comment').each do |comment|
		string_comment = comment.text()
		Job.create(content: string_comment, created_at: post_date)
	end

	more_link = doc.css('a:contains("More")')
	unless more_link.empty?
		base_url = 'https://news.ycombinator.com'
		the_href = more_link.attribute('href')
		hacker_url = base_url + the_href
		gather_jobs( hacker_url, post_date )
	end
end