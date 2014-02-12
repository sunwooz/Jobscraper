class AddUserUserhrefCommentlinkToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :user, :string
    add_column :jobs, :user_href, :string
    add_column :jobs, :comment_link, :string
    add_column :jobs, :hacker_news_job_posts_id, :integer
  end
end