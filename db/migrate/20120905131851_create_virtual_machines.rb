class CreateVirtualMachines < ActiveRecord::Migration
  def change
    create_table :virtual_machines do |t|
      t.integer :workspace_id
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
