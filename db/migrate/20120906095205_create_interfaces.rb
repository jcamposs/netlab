class CreateInterfaces < ActiveRecord::Migration
  def change
    create_table :interfaces do |t|
      t.integer :virtual_machine_id
      t.string :name

      t.timestamps
    end
  end
end
