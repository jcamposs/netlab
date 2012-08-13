class CreateScenes < ActiveRecord::Migration
  def change
    create_table :scenes do |t|
      t.integer :owner_id
      t.string :name
      t.string :definition
      t.string :schema

      t.timestamps
    end
  end
end
