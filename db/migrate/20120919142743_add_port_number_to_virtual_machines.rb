class AddPortNumberToVirtualMachines < ActiveRecord::Migration
  def change
    add_column :virtual_machines, :port_number, :integer, :default => -1

  end
end
