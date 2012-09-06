class CreateCollisionDomains < ActiveRecord::Migration
  def change
    create_table :collision_domains do |t|
      t.string :name

      t.timestamps
    end
  end
end
