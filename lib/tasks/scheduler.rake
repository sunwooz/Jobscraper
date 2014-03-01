require 'nokogiri'
require 'date'
require 'mechanize'
require 'colorize'

namespace :hn do
	desc "get a list of HN Hiring Now links and put in database"
	task :link_populate => :environment do
		whoishiring_page = 'https://news.ycombinator.com/submitted?id=whoishiring'
		hacker_base_url = 'https://news.ycombinator.com/'

		agent = access_proxy()
		page = agent.get(whoishiring_page).body
		print "Page accessed."

		doc = Nokogiri::HTML( page )
		doc.css('a').each do |link|
			link_text = link.text
			if link.text.include?('Ask HN: Who is hiring?')
				job_post_link = hacker_base_url + link.attribute('href')
				date_published = Date.parse( link.text )
				puts "Creating #{link_text}."
				HackerNewsJobPost.create(post_link: job_post_link, post_title: link.text, post_date: date_published)
				puts "#{link_text} added.".blue
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
			puts "Populating jobs for: #{post_title}...".green
			gather_jobs(post_link, post_date)
			puts "Done Populating #{post_title}.".green
			sleep(3)
		end
		puts "All Jobs Stolen!".red
	end
end

desc "Scrape the latest HN hiring post"
task :get_latest_post => :environment do
	#NOT DONE
	whoishiring_page = 'https://news.ycombinator.com/submitted?id=whoishiring'
	hacker_base_url = 'https://news.ycombinator.com/'

	agent = access_proxy()
	page = agent.get(whoishiring_page).body
	puts "Who is Hiring page accessed."

	doc = Nokogiri::HTML( page )

	doc.css('td.title a').each do |link|
		next if link.text.include?('Freelancer?')
		job_info = HackerNewsJobPost.find_by(post_title: link.text)
		next if job_info
		if job_info.nil?
			job_post_link = hacker_base_url + link.attribute('href')
			date_published = Date.parse( link.text )

			HackerNewsJobPost.create(post_title: link.text, post_link: job_post_link, post_date: date_published)
		end
	end

	most_recent_hn_post_db = HackerNewsJobPost.all.order(post_date: :desc).first
	puts "Scraping #{most_recent_hn_post_db.post_title}."
	gather_jobs(most_recent_hn_post_db.post_link, most_recent_hn_post_db.post_date)
end

def access_proxy
	agent = Mechanize.new
	# proxy = '198.23.143.27'
	# puts "Accessing proxy #{proxy}..."
	# agent.set_proxy proxy, 5555
	return agent
end

def gather_jobs(initial_link, post_date)
	agent = access_proxy()
	page = agent.get(initial_link).body
	puts "Mechanize visited #{initial_link}.".blue

	puts "Scraping comments from #{initial_link}".blue
	doc = Nokogiri::HTML( page )
	doc.css('span.comment').each do |comment|
		found_job = Job.find_by(content: comment.to_s)
		if !found_job
			html_comment = comment.to_s
			Job.create(content: html_comment, created_at: post_date)
		end
	end
	puts "Scraped comments from #{initial_link}".blue

	more_link = doc.css('a:contains("More")')
	unless more_link.empty?
		sleep(2)
		base_url = 'https://news.ycombinator.com'
		the_href = more_link.attribute('href')
		hacker_url = base_url + the_href
		gather_jobs( hacker_url, post_date )
	end
	puts "Done scraping!".green
end