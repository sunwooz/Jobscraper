class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.string :alternative_names, array: true, default: []
    end
  end
end
