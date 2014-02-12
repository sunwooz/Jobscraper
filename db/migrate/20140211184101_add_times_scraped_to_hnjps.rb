class AddTimesScrapedToHnjps < ActiveRecord::Migration
  def change
    add_column :hacker_news_job_posts, :times_scraped, :integer
  end
end