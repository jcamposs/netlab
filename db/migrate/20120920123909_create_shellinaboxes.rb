class CreateShellinaboxes < ActiveRecord::Migration
  def change
    create_table :shellinaboxes do |t|
      t.integer :pid
      t.integer :user_id
      t.integer :virtual_machine_id
      t.string :host_ip

      t.timestamps
    end
  end
end
