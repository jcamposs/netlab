# This migration comes from gdrivestrg (originally 20130314120725)
class CreateGdrivestrgPermissionIds < ActiveRecord::Migration
  def change
    create_table :gdrivestrg_permission_ids do |t|
      t.integer :user_id
      t.integer :remoteobject_id
      t.string :permission_id

      t.timestamps
    end
  end
end
