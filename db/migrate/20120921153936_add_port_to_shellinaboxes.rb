class AddPortToShellinaboxes < ActiveRecord::Migration
  def change
    add_column :shellinaboxes, :port_number, :integer, :default => -1

  end
end
