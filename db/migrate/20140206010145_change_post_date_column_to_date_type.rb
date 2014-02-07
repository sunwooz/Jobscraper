class ChangePostDateColumnToDateType < ActiveRecord::Migration
  def change
  	change_column :hacker_news_job_posts, :post_date, :date
  end
end
