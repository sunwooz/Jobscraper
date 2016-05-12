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
	#use this grab the latest page and its comments
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
		if job_info.nil? && link.text.include?('Ask HN: Who is hiring?')
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

	doc.css('tr.athing').each do |tr|
		next if tr.text.strip.include?('Ask HN: Who is hiring?')
		text_content = tr.css('.comment').to_s
		found_job = Job.find_by(content: text_content)
		if Job.count == 1
			last_job = Job.first
		else
			last_job = Job.order('created_at')[-1]
		end

		if tr.css('.ind img')[0]['width'] == "0" && !found_job
			# if comment is first level comment
			# and job doesn't already exist in database
			# save it
			html_comment = text_content
			full_title = ActionView::Base.full_sanitizer.sanitize(html_comment.split('<p>')[0]).strip

			if !full_title.nil?
				title = clean_title(full_title)
			else
				title = "No Title"
			end

			content = html_comment.split('<p>')[1..-1].join(" ")
			Job.create(content: content, created_at: post_date, company: title, header: full_title)
		elsif tr.css('.ind img')[0]['width'] != "0" && !last_job.comments.pluck(:content).include?(text_content)
			# if comment is not first level comment
			# and the job does not already have this comment
			last_job.comments << Comment.create(content: text_content)
			last_job.save
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

def clean_title(text)
	begin
		cleaned_title = text.split("|")[0].split("-")[0].split(",")[0].split("(")[0].split("http")[0].split("•")[0].split("[")[0].strip
	rescue
		cleaned_title = "No Title"
	end
	cleaned_title
end