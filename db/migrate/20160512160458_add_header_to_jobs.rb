class AddHeaderToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :header, :text
  end
end
