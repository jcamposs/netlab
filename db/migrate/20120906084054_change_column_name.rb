class ChangeColumnName < ActiveRecord::Migration
  def up
    rename_column :virtual_machines, :type, :node_type
  end

  def down
    rename_column :virtual_machines, :node_type, :type
  end
end
