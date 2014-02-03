class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
   	  t.text :content
      t.timestamps
    end
  end
end
