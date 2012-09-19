class AddStateToVirtualMachines < ActiveRecord::Migration
  def change
    add_column :virtual_machines, :state, :string, :default => "halted"
  end
end
